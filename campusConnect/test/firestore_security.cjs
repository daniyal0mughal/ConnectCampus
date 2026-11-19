const {test}=require('node:test');
const assert=require('node:assert/strict');
const project='demo-campusconnect';
const base=`http://127.0.0.1:8080/v1/projects/${project}/databases/(default)/documents`;
const name=p=>`projects/${project}/databases/(default)/documents/${p}`;
const fields=data=>Object.fromEntries(Object.entries(data).map(([k,v])=>[k,v===null?{nullValue:null}:{stringValue:String(v)}]));
async function call(url,token,method='GET',body){const response=await fetch(url,{method,headers:{Authorization:`Bearer ${token}`,'Content-Type':'application/json'},body:body?JSON.stringify(body):undefined});return {status:response.status,body:await response.json()};}
function write(path,data,timestamps=[],exists){return {update:{name:name(path),fields:fields(data)},...(exists===undefined?{}:{currentDocument:{exists}}),...(timestamps.length?{updateTransforms:timestamps.map(fieldPath=>({fieldPath,setToServerValue:'REQUEST_TIME'}))}:{})};}
async function commit(token,writes){return call(`${base}:commit`,token,'POST',{writes});}
async function signup(email){const r=await fetch('http://127.0.0.1:9099/identitytoolkit.googleapis.com/v1/accounts:signUp?key=demo-key',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({email,password:'Test-password-123!',returnSecureToken:true})});assert.equal(r.status,200);return r.json();}
function okay(r){assert.equal(r.status,200,JSON.stringify(r.body));}
function denied(r){assert.equal(r.status,403,JSON.stringify(r.body));}

test('Auth and Firestore enforce the complete role and complaint workflow',async()=>{
  const student=await signup('student@test.example'),other=await signup('other@test.example'),admin=await signup('library@test.example'),wrong=await signup('labs@test.example'),superAdmin=await signup('super@test.example');
  for(const [id,n] of [['cs','CS Department'],['medical','Medical Department']]) {
    okay(await commit('owner',[write(`departments/${id}`,{name:n})]));
    for(const category of ['cafeteria','library','labs','academic'])okay(await commit('owner',[write(`categories/${id}_${category}`,{name:category,department_id:id})]));
  }
  const userData=(email,role,department_id=null)=>({full_name:role,email,role,department_id});
  okay(await commit(student.idToken,[write(`users/${student.localId}`,userData('student@test.example','student'),['created_at'],false)]));
  okay(await commit(other.idToken,[write(`users/${other.localId}`,userData('other@test.example','student'),['created_at'],false)]));
  denied(await commit(admin.idToken,[write(`users/${admin.localId}`,userData('library@test.example','dept_admin','cs'),['created_at'],false)]));
  okay(await commit('owner',[write(`users/${superAdmin.localId}`,userData('super@test.example','super_admin'),['created_at'])]));
  denied(await commit(superAdmin.idToken,[write('users/legacy-admin',userData('legacy@test.example','dept_admin','library'),['created_at'],false)]));
  okay(await commit(superAdmin.idToken,[write(`users/${admin.localId}`,userData('library@test.example','dept_admin','cs'),['created_at'],false),write(`users/${wrong.localId}`,userData('labs@test.example','dept_admin','medical'),['created_at'],false)]));
  denied(await commit(student.idToken,[write(`users/${student.localId}`,userData('student@test.example','super_admin'),['created_at'])]));
  denied(await commit(superAdmin.idToken,[write('users/another-super',userData('x@test.example','super_admin'),['created_at'],false)]));
  const id=`${student.localId}_abcdefghijklmnopqrst`;
  assert.equal((await call(`${base}/complaints/${id}`,student.idToken)).status,404);
  const complaint={student_id:student.localId,student_name:'student',category_id:'cs_library',department_id:'cs',title:'Broken light',description:'The reading room light is broken.',status:'Pending',rejection_reason:null,latest_remark:null,last_remark_id:null};
  denied(await commit(student.idToken,[write(`complaints/${id}`,{...complaint,department_id:'medical'},['created_at','updated_at'],false)]));
  denied(await commit(student.idToken,[write(`complaints/${id}`,{...complaint,category_id:'medical_library'},['created_at','updated_at'],false)]));
  denied(await commit(student.idToken,[write(`complaints/${id}`,{...complaint,student_id:other.localId},['created_at','updated_at'],false)]));
  denied(await commit(student.idToken,[write(`complaints/${id}`,{...complaint,status:'Resolved'},['created_at','updated_at'],false)]));
  okay(await commit(student.idToken,[write(`complaints/${id}`,complaint,['created_at','updated_at'],false)]));
  okay(await call(`${base}/complaints/${id}`,student.idToken));
  denied(await call(`${base}/complaints/${id}`,other.idToken));
  denied(await call(`${base}/complaints/${id}`,wrong.idToken));
  denied(await fetch(`${base}/complaints/${id}`).then(async r=>({status:r.status,body:await r.json()})));
  okay(await call(`${base}/complaints/${id}`,admin.idToken));
  okay(await call(`${base}/complaints/${id}`,superAdmin.idToken));
  const stored=(await call(`${base}/complaints/${id}`,'owner')).body;
  const replyId=`${admin.localId}_abcdefghijklmnopqrst`;
  assert.equal((await call(`${base}/complaint_remarks/${replyId}`,admin.idToken)).status,404);
  const updates=(reason,status='Rejected')=>[
    {update:{name:name(`complaints/${id}`),fields:{...stored.fields,...fields({status,rejection_reason:reason,latest_remark:'Duplicate report',last_remark_id:replyId})}},updateTransforms:[{fieldPath:'updated_at',setToServerValue:'REQUEST_TIME'}]},
    write(`complaint_remarks/${replyId}`,{complaint_id:id,admin_id:admin.localId,admin_name:'dept_admin',remark:'Duplicate report',status_set:status},['created_at'],false),
  ];
  denied(await commit(admin.idToken,updates(null)));
  denied(await commit(wrong.idToken,updates('Duplicate')));
  denied(await commit(student.idToken,updates('Duplicate')));
  denied(await commit(admin.idToken,[updates('Duplicate')[0]]));
  okay(await commit(admin.idToken,updates('Duplicate')));
  okay(await call(`${base}/complaint_remarks/${replyId}`,student.idToken));
  denied(await call(`${base}/complaint_remarks/${replyId}`,other.idToken));
  denied(await commit(admin.idToken,[write(`complaint_remarks/${replyId}`,{remark:'Changed history'})]));
  const query={structuredQuery:{from:[{collectionId:'complaints'}],where:{fieldFilter:{field:{fieldPath:'student_id'},op:'EQUAL',value:{stringValue:student.localId}}}}};
  okay(await call(`${base}:runQuery`,student.idToken,'POST',query));
  denied(await call(`${base}:runQuery`,other.idToken,'POST',query));
  denied(await call(`${base}:runQuery`,student.idToken,'POST',{structuredQuery:{from:[{collectionId:'complaints'}]}}));
  okay(await call(`${base}:runQuery`,superAdmin.idToken,'POST',{structuredQuery:{from:[{collectionId:'complaints'}]}}));
  const replyQuery={structuredQuery:{from:[{collectionId:'complaint_remarks'}],where:{fieldFilter:{field:{fieldPath:'complaint_id'},op:'EQUAL',value:{stringValue:id}}}}};
  okay(await call(`${base}:runQuery`,student.idToken,'POST',replyQuery));
  const medicalId=`${other.localId}_abcdefghijklmnopqrst`;
  okay(await commit(other.idToken,[write(`complaints/${medicalId}`,{...complaint,student_id:other.localId,category_id:'medical_library',department_id:'medical'},['created_at','updated_at'],false)]));
  okay(await call(`${base}/complaints/${medicalId}`,wrong.idToken));
  denied(await call(`${base}/complaints/${medicalId}`,admin.idToken));
  for(const [account,department] of [[admin,'cs'],[wrong,'medical']]) {
    okay(await call(`${base}:runQuery`,account.idToken,'POST',{structuredQuery:{from:[{collectionId:'complaints'}],where:{fieldFilter:{field:{fieldPath:'department_id'},op:'EQUAL',value:{stringValue:department}}}}}));
  }
  console.log('Verified student-only signup, privileged provisioning, owner/department isolation, routing, atomic replies, immutable history and scoped queries.');
});

test('catalog migration refuses guessed reassignment and is repeatable',async()=>{
  // Clear only this isolated emulator project's synthetic documents.
  const cleared=await fetch(`http://127.0.0.1:8080/emulator/v1/projects/${project}/databases/(default)/documents`,{method:'DELETE'});
  assert.equal(cleared.status,200);
  const syncCatalog=require('../tools/catalog.cjs');
  const api=async(url,method='GET',body)=>{
    const r=await call(url.replace('https://firestore.googleapis.com','http://127.0.0.1:8080'),'owner',method,body);
    if(r.status!==200)throw new Error(JSON.stringify(r.body));
    return r.body;
  };
  const names={cafeteria:'Cafeteria',library:'Library',labs:'Laboratories & IT',academic:'Teaching & Academic Affairs'};
  for(const [id,n] of Object.entries(names))okay(await commit('owner',[write(`departments/${id}`,{name:n}),write(`categories/${id}`,{name:n,department_id:id})]));
  okay(await commit('owner',[write('complaints/legacy',{department_id:'library'})]));
  await assert.rejects(syncCatalog(api,project),/Explicit reassignment/);
  okay(await call(`${base}/departments/library`,'owner'));
  okay(await commit('owner',[{delete:name('complaints/legacy')}]));
  await syncCatalog(api,project);
  await syncCatalog(api,project);
  const departments=await call(`${base}/departments`,'owner');
  const categories=await call(`${base}/categories`,'owner');
  assert.deepEqual(departments.body.documents.map(d=>d.name.split('/').pop()).sort(),['cs','medical']);
  assert.equal(categories.body.documents.length,8);
  for(const department of ['cs','medical'])assert.equal(categories.body.documents.filter(d=>d.fields.department_id.stringValue===department).length,4);
});
