// Local operator tool. Uses an existing Firebase CLI login; never prints credentials.
const path = require('node:path');
const auth = require(path.join(process.env.APPDATA, 'npm/node_modules/firebase-tools/lib/auth.js'));
const project = 'campusconnect-9c792';
async function main() {
  const account = auth.getGlobalDefaultAccount();
  if (!account) throw new Error('Run Firebase CLI login first.');
  const token = await auth.getAccessToken(account.tokens.refresh_token, ['https://www.googleapis.com/auth/cloud-platform','https://www.googleapis.com/auth/firebase']);
  async function api(url, method = 'GET', data) {
    const res = await fetch(url, {method, headers:{Authorization:`Bearer ${token.access_token}`, 'Content-Type':'application/json'},body:data ? JSON.stringify(data) : undefined});
    const body = await res.json();
    if (!res.ok) throw new Error(`${res.status}: ${body.error?.message}`);
    return body;
  }
  if (process.argv[2] === 'catalog-inspect') {
    const base=`https://firestore.googleapis.com/v1/projects/${project}/databases/(default)/documents`;
    for(const collection of ['departments','categories','complaints','users']) {
      const result=await api(`${base}:runQuery`,'POST',{structuredQuery:{from:[{collectionId:collection}],select:{fields:[{fieldPath:'department_id'},{fieldPath:'role'}]}}});
      console.log(JSON.stringify({collection,records:result.filter(r=>r.document).map(r=>({id:r.document.name.split('/').pop(),department:r.document.fields?.department_id?.stringValue,role:r.document.fields?.role?.stringValue}))}));
    }
  } else if (process.argv[2] === 'catalog-update') {
    await require('./catalog.cjs')(api,project);
  } else if (process.argv[2] === 'inspect') {
    const billing = await api(`https://cloudbilling.googleapis.com/v1/projects/${project}/billingInfo`);
    console.log(JSON.stringify({billingEnabled:billing.billingEnabled}));
    try { const config = await api(`https://identitytoolkit.googleapis.com/admin/v2/projects/${project}/config`); console.log(JSON.stringify({emailPassword:config.signIn?.email,authorizedDomains:config.authorizedDomains})); } catch(e) {console.log(e.message);}
  } else if (process.argv[2] === 'enable') {
    for (const service of ['firestore.googleapis.com','identitytoolkit.googleapis.com']) {
      await api(`https://serviceusage.googleapis.com/v1/projects/${project}/services/${service}:enable`,'POST',{});
      console.log(`Enabled ${service}`);
    }
  } else if (process.argv[2] === 'bootstrap') {
    const base=`https://firestore.googleapis.com/v1/projects/${project}/databases/(default)/documents`;
    const fields=data=>Object.fromEntries(Object.entries(data).map(([k,v])=>[k,v===null?{nullValue:null}:{stringValue:v}]));
    await require('./catalog.cjs')(api,project);
    const email='superadmin1122@gmail.com';
    const lookup=await api(`https://identitytoolkit.googleapis.com/v1/projects/${project}/accounts:lookup`,'POST',{email:[email]});
    let user=lookup.users?.[0];
    if(!user) {
      const created=await api(`https://identitytoolkit.googleapis.com/v1/projects/${project}/accounts`,'POST',{
        targetProjectId:project,localId:'campusconnect-super-admin',email,displayName:'SuperAdmin',disabled:true,
        password:require('node:crypto').randomBytes(48).toString('base64url'),
      });
      user={localId:created.localId,disabled:true};
    }
    let profile;
    try {profile=await api(`${base}/users/${user.localId}`);}catch(e){if(!e.message.startsWith('404:'))throw e;}
    if(profile && profile.fields.role.stringValue!=='super_admin')throw new Error('Existing account is not a super admin; refusing promotion.');
    if(!profile) {
      if(user.localId!=='campusconnect-super-admin'||!user.disabled)throw new Error('Existing account needs developer review before promotion.');
      await api(`${base}:commit`,'POST',{writes:[{update:{name:`projects/${project}/databases/(default)/documents/users/${user.localId}`,fields:fields({full_name:'SuperAdmin',email,role:'super_admin',department_id:null})},currentDocument:{exists:false},updateTransforms:[{fieldPath:'created_at',setToServerValue:'REQUEST_TIME'}]}]});
    }
    await api(`https://identitytoolkit.googleapis.com/v1/projects/${project}/accounts:update`,'POST',{localId:user.localId,disableUser:false});
    console.log('SuperAdmin account is ready. Use Forgot password to choose the password. No password was printed or saved.');
  } else if (process.argv[2] === 'auth') {
    await api(`https://identitytoolkit.googleapis.com/admin/v2/projects/${project}/config?updateMask=signIn.email`,'PATCH',{signIn:{email:{enabled:true,passwordRequired:true}}});
    console.log('Email/password sign-in enabled.');
  } else { throw new Error('Use inspect, catalog-inspect, catalog-update, enable, auth, or bootstrap.'); }
}
main().catch(e => {console.error(e.message);process.exitCode=1;});
