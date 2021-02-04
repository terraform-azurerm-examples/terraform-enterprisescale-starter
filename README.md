# Introduction 

This is a Enterprise Scale Landing Zone repo complete with a subscription vending machine.

## Workflow

<img src="imgs\hld.PNG" alt="high level design"/>

1.	Engineer creates a new feature branch off main (or triggers the subscription vending pipeline, which in turn creates a feature branch – 1b.)
1.	Engineer commits changes to feature branch which triggers continuous integration builds, running Terraform validate steps
1.	Engineer (or subscription creation pipeline) creates a pull request into main branch
1.	Continuous integration build validation pipeline runs for main, running Terraform validate steps
1.	After build validation, an automated pull request is created for main into canary
1.	Pipeline is triggered to run Terraform validate and Terraform plan steps. A comment is posted to the pull request with changes to apply to canary. Once approved, the pipeline runs Terraform apply and changes to the canary environment are deployed. 
1.	 After deployment to canary is successful, an automated pull request is created for canary into prod
1.	Pipeline is triggered to run Terraform validate and Terraform plan steps. A comment is posted to the pull request with changes to apply to prod. Once approved, the pipeline runs Terraform apply and changes to the prod environment are deployed.

## Branching Strategy

<img src="imgs\branching.PNG" alt="branch strategy"/>

The following branching strategy will be enforced via branch policy and pipeline conditions. 

Main, canary and prod are long lived branches. When new development work is identified, such as changing policy, a new feature branch will be created off main.

Development work continues in this branch and will be merged back to main, which in turn will be merged into canary, and finally canary will be merged into prod. Feature branches should be deleted as soon as they are successfully merged to main. 

Similarly, if a new subscription needs created, the subscription-vending-machine.yml pipeline will run and create a feature branch off main, and automate a pull request back into the main branch.

Merging must follow this pattern, and is enforced via conditions set in pipelines. For example, this condition in **tf-plan-apply-canary.yml** ensures that the pipeline only continues if the pipeline was triggered on CI for canary, or on a PR from main into canary. 

```
condition: |
          not(
            or(
              and(
                eq(variables['Build.Reason'], 'PullRequest'),
                eq(variables['System.PullRequest.SourceBranch'], 'refs/heads/main')
                ),
              and(
                in(variables['Build.Reason'], 'IndividualCI', 'BatchedCI', 'Manual'),
                eq(variables['Build.SourceBranchName'],'canary')
              )
            )
          )
```

Use of rebase and fast forward is recommended for merges into dev and prod. 

### Pipeline breakdown

The deployment pipelines consist of two stages:
Stage 1 – Terraform validate and plan
Stage 2 – Terraform apply

1.	A pull request is made from main into canary. Stage 1 of the pipeline triggers and carries out validation on the Terraform files. 
2.	On success, the pipeline writes any planned Terraform changes to the pull request via a comment. This is performed by the script located here: **./scripts/TerraformAnnotate.ps1**.
3.	Once this comment has been approved and the pull request has been approved (and other checks have passed), main will be merged to canary, and the pipeline will trigger again. Stage 1 produces a tfplan. 
4.	Stage 2 runs if Stage 1 succeeds and consumes the tfplan artefact to perform the terraform apply step.
5.	Any changes in the plan are carried out by Terraform
6.	If successful, the pipeline creates an automated pull request into the prod branch, which triggers **tf-plan-apply-prod.yml**

### Branch Protection

Through the use of approvals and branch protection policy, we can ensure that any changes in policy or Azure resources introduced by an engineer must pass multiple, automated and manual checks before changes are deployed to canary and production environments.

Once a pull request has been opened, there are 3 checks that must pass before code will be merged into the target branch:

1.	Code must be approved by at least two reviewers. This ensures that engineers cannot approve their own changes

2.	The build validation pipeline must complete successfully (tf-build-validation.yml)

3.	Pull request comments must be marked as ‘resolved’ to ensure that Terraform changes have been reviewed and accepted
