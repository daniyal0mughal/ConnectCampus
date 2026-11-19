// Developer-only catalog migration. Called with an authenticated REST client.
module.exports = async function syncCatalog(api, project) {
  const base=`https://firestore.googleapis.com/v1/projects/${project}/databases/(default)/documents`;
  const oldNames={cafeteria:'Cafeteria',library:'Library',labs:'Laboratories & IT',academic:'Teaching & Academic Affairs'};
  const departments={cs:'CS Department',medical:'Medical Department'};
  const fields=data=>Object.fromEntries(Object.entries(data).map(([key,value])=>[key,{stringValue:value}]));
  const {transaction}=await api(`${base}:beginTransaction`,'POST',{options:{readWrite:{}}});
  try {
    const records={};
    for(const collection of ['users','complaints','departments','categories']) {
      const result=await api(`${base}:runQuery`,'POST',{transaction,structuredQuery:{from:[{collectionId:collection}],...(['users','complaints'].includes(collection)?{select:{fields:[{fieldPath:'department_id'}]}}:{})}});
      records[collection]=result.filter(r=>r.document).map(r=>r.document);
    }
    for(const collection of ['users','complaints']) {
      if(records[collection].some(d=>Object.hasOwn(oldNames,d.fields?.department_id?.stringValue))) {
        throw new Error(`Existing ${collection} still reference old departments. Explicit reassignment is required; no data changed.`);
      }
    }
    const writes=[];
    function ensure(collection,id,data) {
      const expected=fields(data),name=`projects/${project}/databases/(default)/documents/${collection}/${id}`;
      const current=records[collection].find(d=>d.name===name);
      if(current) {
        if(Object.keys(current.fields).length!==Object.keys(expected).length || Object.entries(data).some(([k,v])=>current.fields[k]?.stringValue!==v))throw new Error(`Conflicting catalog entry ${collection}/${id}; no data changed.`);
      } else writes.push({update:{name,fields:expected},currentDocument:{exists:false}});
    }
    for(const [department,name] of Object.entries(departments)) {
      ensure('departments',department,{name});
      for(const [category,name] of Object.entries(oldNames))ensure('categories',`${department}_${category}`,{name,department_id:department});
    }
    for(const [id,name] of Object.entries(oldNames)) {
      for(const collection of ['departments','categories']) {
        const current=records[collection].find(d=>d.name.endsWith(`/${collection}/${id}`));
        if(!current)continue;
        const expected=collection==='departments'?1:2;
        if(Object.keys(current.fields).length!==expected || current.fields.name?.stringValue!==name || (collection==='categories'&&current.fields.department_id?.stringValue!==id))throw new Error(`Legacy catalog entry ${collection}/${id} was edited; no data changed.`);
        writes.push({delete:current.name,currentDocument:{updateTime:current.updateTime}});
      }
    }
    await api(`${base}:commit`,'POST',{transaction,writes});
    console.log('Catalog verified: CS Department and Medical Department, each with four categories. No complaints or account assignments changed.');
  } catch(error) {
    await api(`${base}:rollback`,'POST',{transaction}).catch(()=>{});
    throw error;
  }
};
