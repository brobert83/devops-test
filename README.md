# General notes [![Build Status](https://travis-ci.com/brobert83/devops-test.svg?branch=master)](https://travis-ci.com/brobert83/devops-test)

This application is built using TravisCI.

The environment creation scripts were tested first using this machine [devops-test-vm](https://github.com/brobert83/devops-test-vm)

The specification is here [Technical test](docs/TechnicalTest.md)

The build will:
- Run the tests
- Provision a environment in GCP (every branch gets it's own environment)
- Deploy the application 
- Start the application
- Wait until it is available on a public IP

There are two modes, _classic_ with computes instances etc, and _kubernetes_ with GKE.

Branches that start with `feature` will trigger a Classic deployment.

Branches that start with `gke_feature` will trigger a Kubernetes deployment.

## Implementation details

- The build is configured to run against my personal GCP account
    - to make it run against another account:
        - create a GCP project
        - create a service account with owner permissions
        - create a key for that account
        - encrypt the key for Travis using `travis encrypt-file --pro ${key_file}` 
          - you will need to be have the travis cli installed and travis needs to be aware of the repo under which you want to encrypt 
          - replace the line just below `before_install:` in `.travis.yml` with the one in the output of that command
          - more details about this [here](https://docs.travis-ci.com/user/encrypting-files/)
        - edit the `.travis.yml` global variables to point to your project (project name, service account name, etc)

- When a branch is created or a commit is pushed to a branch, this build will create a environment specific to that branch        

### CLASSIC deployment 
- The name of the environment is the branch name with all characters but letters and numbers removed (due to GCP naming restrictions for various resources)            
- The build will first attempt to delete the branch specific environment before creating it
- This is the output of a successful build: https://travis-ci.com/github/brobert83/devops-test/builds/186913415
- I will keep this one alive for a while http://35.190.76.97 

### KUBERNETES deployment
- All branches are deployed in a single cluster but with the resources namespaced
- A namespace is created for each branch
- If the cluster does not exist it will be created
- This is the output of a successful build: https://travis-ci.com/github/brobert83/devops-test/builds/187123554
- This one is also live being served from the GKE cluster http://35.232.58.146
    
#### At the end of the build log, it shows where the app is deployed 
![Alt text](docs/output_target.png?raw=true)

# Caveats
- On branch delete the environment will NOT be deleted (I don't know how to do that yet)
  - to delete:
    - run `travis/classic/delete.sh ${branch_name} ${project} ${zone}` for classic 
    - run `travis/kubernetes/delete.sh ${branch_name}` for gke 
    - use the dev environment machine [devops-test-vm](https://github.com/brobert83/devops-test-vm) or another environment where you have gcloud access
- The Kubernetes deployment is missing liveness and readiness probes, will add later