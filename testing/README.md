# Test Framework


Each test is described in a json file. For basic tests where all the nodes are populated with the same script use a format the first example. It will populate the number for nodes as specified in 'nodes'. For each node it will run any puppet classes specified in 'pre-reqs' then run the script from script in each node.

    {
    	"nodes": 2,
    	"description": "Install a standard cluster",

    	"pre-reqs": [
    	],

    	"checkResults": [
        	"clusterOk"
    	],

	}

If each node needs a different script run on it add the 'scriptsPerNode' array entry 0 is run on node 1, entry 1 on node 2 etc

    {
    	"nodes": 2,
    	"description": "Install a standard cluster",

    	"pre-reqs": [
    	],

    	"checkResults": [
        	"clusterOk"
    	],

    	"scriptsPerNode" : [
        	 "prov_setup.pp",
         	"prov_run.pp"
    	]
	}
