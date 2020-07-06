
`
globalvar alphabet = [${Object.keys(mappings).map(x => "p'"+x+"'").join(", ")}]
globalvar alphabetMappings = [${Object.values(mappings).map(mapping => "["+mapping.map(x => "p'"+x+"'").join(", ")+"]")}]
`
