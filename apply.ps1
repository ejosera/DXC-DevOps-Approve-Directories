$terraformDirectories = Get-ChildItem -Directory
$bkstrgkey = ""

## Seccion: triger none
$yamlLines = @"
## Seccion: triger none
trigger: none

"@
Add-content DXC-DevOps-Apply-Approve-Directories.yaml $yamlLines


## Seccion: de pool
$yamlLines = @"
## Seccion: de pool
pool:
  vmImage: ubuntu-latest

"@
Add-content DXC-DevOps-Apply-Approve-Directories.yaml $yamlLines


## Seccion: variables del backend
$yamlLines = @"
## Seccion: variables del backend
variables:
  bkstrgrg: "terraformtfstate"
  bkstrg: "terraformtfstatecicd"
  bkcontainer: "tfstate"
  bkstrgkey: "terraformcicd"

"@
Add-content DXC-DevOps-Apply-Approve-Directories.yaml $yamlLines


## Seccion: Stages
$yamlLines = @"
## Seccion: Stages
stages:

"@
Add-content DXC-DevOps-Apply-Approve-Directories.yaml $yamlLines


## Stage1 tfvalidate job validate
$yamlLines = @"
## Seccion: Stages
  - stage: tfvalidate
    jobs:
      - job: validate
        continueOnError: false
        steps:
          # install
          - task: TerraformInstaller@1
            displayName: tfinstall
            inputs:
              terraformVersion: 'latest'
          # init
          - task: TerraformTaskV4@4
            displayName: init
            inputs:
              provider: 'azurerm'
              command: 'init'
              backendServiceArm: 'Visual Studio Enterprise(4abab78e-cc44-4dc6-b6c0-35280c169a76)'
              backendAzureRmResourceGroupName: '`$(bkstrgrg)`'
              backendAzureRmStorageAccountName: '`$(bkstrg)`'
              backendAzureRmContainerName: '`$(bkcontainer)`'
              backendAzureRmKey: '`$(bkstrgkey)`'
          # validate
          - task: TerraformTaskV4@4
            displayName: validate
            inputs:
              provider: 'azurerm'
              command: 'validate'

"@
Add-content DXC-DevOps-Apply-Approve-Directories.yaml $yamlLines


## Este stage se ejecuta tantas veces como directorios haya en el código de terraform
foreach( $terraformDirectory in $terraformDirectories) {

$yamlLines = @"
    $terraformDirectory.Name

  - stage: plan
    displayName: plan
    condition: succeeded('tfvalidate')
    dependsOn: tfvalidate
    jobs:
      - job: plan
        steps:
          # install terraform
          - task: TerraformInstaller@1
            displayName: plan - install terraform
            inputs:
              terraformVersion: 'latest'
          # init
          - task: TerraformTaskV4@4
            displayName: Initialize Terraform
            inputs:
              provider: 'azurerm'
              command: 'init'
              backendServiceArm: 'Visual Studio Enterprise(4abab78e-cc44-4dc6-b6c0-35280c169a76)'
              backendAzureRmResourceGroupName: '`$(bkstrgrg)`'
              backendAzureRmStorageAccountName: '`$(bkstrg)``'
              backendAzureRmContainerName: '`$(bkcontainer)'
              backendAzureRmKey: '`$(bkstrgkey)`'
          # plan
          - task: TerraformTaskV4@4
            displayName: Plan Terraform Deployment
            inputs:
              provider: 'azurerm'
              command: 'plan'
              environmentServiceNameAzureRM: 'DevTestServiceConnection'

  # Approve
  - stage: Approve
    displayName: Approve
    condition: succeeded('plan')
    dependsOn: plan
    jobs:
    - job: approve
      displayName: Wait for approval
      pool: server
      steps: 
      - task: ManualValidation@0
        timeoutInMinutes: 60
        inputs:
          notifyUsers: 'joseramon.lopez@dxc.com'
          instructions: 'Review the plan in the next hour'   
                
  - stage: tfdeploy
    condition: succeeded('Approve')
    dependsOn: Approve
    jobs:
      - job: apply
        steps:
          - task: TerraformInstaller@1
            displayName: tfinstall
            inputs:
              terraformVersion: 'latest'
          - task: TerraformTaskV4@4
            displayName: init
            inputs:
              provider: 'azurerm'
              command: 'init'
              backendServiceArm: 'Visual Studio Enterprise(4abab78e-cc44-4dc6-b6c0-35280c169a76)'
              backendAzureRmResourceGroupName: '`$(bkstrgrg)`'
              backendAzureRmStorageAccountName: '`$(bkstrg)`'
              backendAzureRmContainerName: '`$(bkcontainer)`'
              backendAzureRmKey: '`$(bkstrgkey)`'
          - task: TerraformTaskV4@4
            displayName: apply
            inputs:
              provider: 'azurerm'
              command: 'apply'
              environmentServiceNameAzureRM: 'DevTestServiceConnection'
"@
Add-content DXC-DevOps-Apply-Approve-Directories.yaml $yamlLines


}




#out-file -FilePath DXC-DevOps-Apply-Approve-Directories.yaml
#    workingDirectory: '$(System.DefaultWorkingDirectory)/skip-step'