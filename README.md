# General notes [![Build Status](https://travis-ci.com/brobert83/devops-test.svg?branch=master)](https://travis-ci.com/brobert83/devops-test)

This application is built using TravisCI.

The specification is here [Technical test](docs/TechnicalTest.md)

The build will:
- Run the tests
- Provision a environment in GCP (every branch gets it's own environment)
- Deploy the application 
- Start the application
- Wait until it is available on a public IP

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
    - the name of the environment is the branch name with all characters but letters and numbers removed (due to GCP naming restrictions for various resources)            
    - the build will first attempt to delete the branch specific environment before creating it
    - this is the output of the last successful build: https://travis-ci.com/github/brobert83/devops-test/builds/186913415
    - at the end it shows where the app is deployed 
    ![Alt text](docs/output_target.png?raw=true)
    - I will keep this one alive for a while http://35.190.76.97 
    
- The environment creation scripts were largely developed using this environment [devops-test-vm](https://github.com/brobert83/devops-test-vm)    

# Caveats
- On branch delete the environment will NOT be deleted (I don't know how to do that yet)
  - to delete it run `travis/delete.sh ${branch_name} ${zone}` 
    - use the dev environment machine [devops-test-vm](https://github.com/brobert83/devops-test-vm) or another environment where you have gcloud access
- Travis won't build on master (don't know why, need to look into it, don't really want to fix it, I can commit on master without building a env)     
  - maybe I'll configure travis to provision only for specific branch names, ones starting with `feature/` for example (and fix the master build)  
