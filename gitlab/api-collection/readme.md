<p align="center"><h1 align="center">Api Collection</h1></p>
<p align="center">api-usage examples</p>

### Table of Contents

- [Setup](#setup)
- [Usage](#usage)
    - #### list
      - [listTotalPages](#listTotalPages)
      - [listPipelineJobs](#listPipelineJobs)
      - [listRepositoryBranches](#listRepositoryBranches)
      - [listRepositoryTags](#listRepositoryTags)
      - [listRepositoryPipelines](#listRepositoryPipelines)
      - [listRepositoryTriggerTokens](#listRepositoryTriggerTokens)
    - #### delete
      - [deleteRepositoryBranch](#deleteRepositoryBranch)
    - #### edit
      - [editProjectDefaultBranch](#editProjectDefaultBranch)
    - #### create
      - [createRepositoryBranch](#createRepositoryBranch)
      - [createTriggerToken](#createTriggerToken)
      - [createNewPipeline](#createNewPipeline)
    - #### get
      - [getSingleProject](#getSingleProject)
 - #### Examples
    - [createNewPipeline.sh](./examples/createNewPipeline.sh)


<!-- ################################################################ -->
<!-- SETUP -->
<!-- ################################################################ -->

<p>
<h2 align="left"  id="setup">Setup</h2>
</p>
<p align="left">
  To utilize the GitLab API collection effectively, ensure the following components are installed and configured on your system:
</p>

<p align="justify"> 
</p>
<!-- ################################################################ -->
<!-- SETUP 0 -->
<!-- ################################################################ -->

<h4 id="curl">curl</h4>
<p align="justify"> 
	
 cURL is a command-line tool for making HTTP requests. You can install it via your system's package manager. 
 
```
sudo apt-get install curl
```
</p>

<!-- ################################################################ -->
<!-- SETUP 1 -->
<!-- ################################################################ -->

<h4 id="jq">jq</h4>
<p align="justify"> 
  
 jq is a lightweight and flexible command-line JSON processor. You can install it using your system's package manager. 
 
```bash
sudo apt-get install jq
```
</p>

<!-- ################################################################ -->
<!-- SETUP 2 -->
<!-- ################################################################ -->

<h4 id="yq">yq</h4>
<p align="justify"> 
  
 yq is a lightweight and portable command-line YAML, JSON and XML processor.
 
```bash
sudo curl -X GET "https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64" -O && cp ./yq_linux_amd64 /usr/bin/yq && chmod +x /usr/bin/yq
```
</p>

<!-- ################################################################ -->
<!-- SETUP 3 -->
<!-- ################################################################ -->

<h4 id="sed">sed</h4>
<p align="justify"> 
  
  sed ("stream editor") is a Unix utility that parses and transforms text, using a simple, compact programming language. 
  
```bash
sudo apt-get install sed
```
</p>

<!-- ################################################################ -->
<!-- USAGE -->
<!-- ################################################################ -->

<p>
<h2 align="left"  id="usage">Usage</h2>
</p>
<p align="left">
I want as many things as possible to be reusable, so that each function is self-sufficient and contains everything it needs.
</p>

<p align="justify"> 
</p>
<!-- ################################################################ -->
<!-- LIST listTotalPages -->
<!-- ################################################################ -->

<p>
<h4 id="listTotalPages">listTotalPages</h4>
- Get a list of rest x-pages for given call.
</p>

<p align="justify"> 
	
```bash
$listTotalPages $user_access_token $gitlab_endpoint 
```

```bash
function listTotalPages() {
  local user_access_token="${1}"
  local gitlab_endpoint="${2}"  
  
  curl                                             \
    --fail                                         \
    --silent                                       \
    --head                                         \
    --header "PRIVATE-TOKEN: ${user_access_token}" \
    --request GET -G                               \
    --url "${gitlab_endpoint}"                     |
    sed '/x-total-pages/!d'                        |
    sed 's/[^[:digit:]]//g'                                                           
};
```

<!-- ################################################################ -->
<!-- LIST listPipelineJobs -->
<!-- ################################################################ -->


<p>
<h4 id="listPipelineJobs">listPipelineJobs</h4>
- Get a list of jobs for a pipeline.
</p>

<p align="justify"> 
	
```bash
readarray -t elements < <(
  jq -c '.[]' <<< $listPipelineJobs $user_access_token $project_id $pipeline_id 
);

for element in "${elements[@]}"; do jq -rc '.[]' <<< "${element}"; done
```

```bash
function listPipelineJobs() {
  local user_access_token="${1}"
  local project_id="${2}"  
  local pipeline_id="${3}"  

  local gitlab_endpoint=(
    "${CI_API_V4_URL}/projects/${project_id}/pipelines/${pipeline_id}/jobs"
  )
  
  # consider to loop over x-pages for given endpoint
  curl                                             \
    --fail                                         \
    --silent                                       \
    --header "PRIVATE-TOKEN: ${user_access_token}" \
    --request GET -G                               \
    --url "${gitlab_endpoint}"                     \
    --data "page=0"				   \
    --data "per_page=100"
};
```
</p>

<!-- ################################################################ -->
<!-- LIST listRepositoryBranches -->
<!-- ################################################################ -->

<p>
<h4 id="listRepositoryBranches">listRepositoryBranches</h4>
- Get a list of repository branches from a project, sorted by name alphabetically.
</p>

<p align="justify"> 
	
```bash
readarray -t elements < <(
  jq -c '.[]' <<< $listRepositoryBranches $user_access_token $project_id 
);

for element in "${elements[@]}"; do jq -rc '.[]' <<< "${element}"; done
```

```bash
function listRepositoryBranches() {
  local user_access_token="${1}"
  local project_id="${2}"  

  local gitlab_endpoint=(
    "${CI_API_V4_URL}/projects/${project_id}/repository/branches"
  )

  # consider to loop over x-pages for given endpoint
  curl                                             \
    --fail                                         \
    --silent                                       \
    --header "PRIVATE-TOKEN: ${user_access_token}" \
    --request GET -G                               \
    --url "${gitlab_endpoint}"                     \
    --data "page=0"				   \
    --data "per_page=100"
};
```
</p>

<!-- ################################################################ -->
<!-- LIST listRepositoryTags -->
<!-- ################################################################ -->

<p>
<h4 id="listRepositoryTags">listRepositoryTags</h4>
- Get a list of repository tags from a project, sorted by update date and time in descending order.
</p>

<p align="justify"> 
	
```bash
readarray -t elements < <(
  jq -c '.[]' <<< $listRepositoryBranches $user_access_token $project_id 
);
for element in "${elements[@]}"; do jq -rc '.[]' <<< "${element}"; done
```

```bash
function listRepositoryTags() {

  local user_access_token="${1}"
  local project_id="${2}"  

  local gitlab_endpoint=(
    "${CI_API_V4_URL}/projects/${project_id}/repository/tags"
  );

  # consider to loop over x-pages for given endpoint
  curl                                             \
    --fail                                         \
    --silent                                       \
    --header "PRIVATE-TOKEN: ${user_access_token}" \
    --request GET -G                               \
    --url "${gitlab_endpoint}"                     \
    --data "page=0"				   \
    --data "per_page=100"
};
```
</p>

<!-- ################################################################ -->
<!-- LIST listRepositoryPipelines -->
<!-- ################################################################ -->

<p>
<h4 id="listRepositoryPipelines">listRepositoryPipelines</h4>
- Get a list of repository tags from a project, sorted by update date and time in descending order.
</p>  

<p align="justify"> 
	
```bash
readarray -t elements < <(
  jq -c '.[]' <<< $listRepositoryPipelines $user_access_token $project_id 
);
for element in "${elements[@]}"; do jq -rc '.[]' <<< "${element}"; done
```

```bash
function listRepositoryPipelines() {
  local user_access_token="${1}"
  local project_id="${2}"  

  local gitlab_endpoint=(
    "${CI_API_V4_URL}/projects/${project_id}/pipelines"
  );

  # consider to loop over x-pages for given endpoint
  curl                                             \
    --fail                                         \
    --silent                                       \
    --header "PRIVATE-TOKEN: ${user_access_token}" \
    --request GET -G                               \
    --url "${gitlab_endpoint}"                     \
    --data "page=0"				   \
    --data "per_page=100"
};
```
</p>

<!-- ################################################################ -->
<!-- LIST listRepositoryTriggerTokens -->
<!-- ################################################################ -->

<p>
<h4 id="listRepositoryTriggerTokens">listRepositoryTriggerTokens</h4>
- Get a list of a project’s pipeline trigger tokens.
</p>  

<p align="justify"> 
	
```bash
readarray -t elements < <(
  jq -c '.[]' <<< $listRepositoryTriggerTokens $user_access_token $project_id 
);
for element in "${elements[@]}"; do jq -rc '.[]' <<< "${element}"; done
```

```bash
function listRepositoryTriggerTokens() {
  local user_access_token="${1}"
  local project_id="${2}"  

  local gitlab_endpoint=(
    "${CI_API_V4_URL}/projects/${project_id}/triggers"
  );

  # consider to loop over x-pages for given endpoint
  curl                                             \
    --fail                                         \
    --silent                                       \
    --header "PRIVATE-TOKEN: ${user_access_token}" \
    --request GET -G                               \
    --url "${gitlab_endpoint}"                     \
    --data "page=0"				   \
    --data "per_page=100"
};
```
</p>

<!-- ################################################################ -->
<!-- DELETE deleteRepositoryBranch -->
<!-- ################################################################ -->

<p>
<h4 id="deleteRepositoryBranch">deleteRepositoryBranch</h4>
- Delete a branch from the repository.
</p>

<p align="justify"> 
	
```bash
$deleteRepositoryBranch $user_access_token $project_id $project_branch
```

```bash
function deleteRepositoryBranch() {
  local user_access_token="${1}"
  local project_id="${2}"  
  local user_access_token="${3}"

  local gitlab_endpoint=(
    "${CI_API_V4_URL}/projects/${project_id}/repository/branches/${project_branch}"
  );

  curl                                             \
    --fail                                         \
    --silent                                       \
    --header "PRIVATE-TOKEN: ${user_access_token}" \
    --request DELETE                               \
    --url "${gitlab_endpoint}"                                                        
};
```
</p>

<!-- ################################################################ -->
<!-- EDIT editProjectDefaultBranch -->
<!-- ################################################################ -->

<p>
<h4 id="editProjectDefaultBranch">editProjectDefaultBranch</h4>
- Updates an existing project default branch.
</p>

<p align="justify"> 
	
```bash
$editProjectDefaultBranch $user_access_token $project_id $project_branch
```

```bash
function editProjectDefaultBranch() {
  local user_access_token="${1}"
  local project_id="${2}"  
  local project_branch="${3}"

  local gitlab_endpoint=(
    "${CI_API_V4_URL}/projects/${project_id}"
  );

  curl                                       	   \
    --fail                                         \
    --silent                                       \
    --header "PRIVATE-TOKEN: ${user_access_token}" \
    --request PUT                                  \
    --url "${gitlab_endpoint}"                     \
    --data "default_branch=${project_branch}"
};
```
</p>

<!-- ################################################################ -->
<!-- CREATE createRepositoryBranch -->
<!-- ################################################################ -->

<p>
<h4 id="createRepositoryBranch">createRepositoryBranch</h4>
- Create a new branch in the repository.
</p>

<p align="justify"> 
	
```bash
$createRepositoryBranch $user_access_token $project_id $project_branch $project_ref
```

```bash
function editProjectDefaultBranch() {
  local user_access_token="${1}"
  local project_id="${2}"  
  local project_branch="${3}"
  local project_ref="${3:HEAD}"

  local gitlab_endpoint=(
    "${CI_API_V4_URL}/projects/${project_id}/repository/branches"
  );

  curl                                             \
    --fail                                         \
    --silent                                       \
    --header "PRIVATE-TOKEN: ${user_access_token}" \
    --request PUT                                  \
    --url "${gitlab_endpoint}"                     \
    --data "branch=${project_branch}"              \
    --data "ref=${project_ref}" 
};
```
</p>

<!-- ################################################################ -->
<!-- CREATE createTriggerToken -->
<!-- ################################################################ -->

<p>
<h4 id="createTriggerToken">createTriggerToken</h4>
- Create a pipeline trigger token for a project.
</p>

<p align="justify"> 
	
```bash
$createTriggerToken $user_access_token $project_id $project_ref
```

```bash
function createTriggerToken() {
  local user_access_token="${1}"
  local project_id="${2}"

  local gitlab_endpoint=(
    "${CI_API_V4_URL}/projects/${project_id}/triggers"
  );

  curl                                             \
    --fail                                         \
    --silent                                       \
    --header "PRIVATE-TOKEN: ${user_access_token}" \
    --request POST                                 \
    --form description="${CI_PROJECT_NAME}"        \
    --url "${gitlab_endpoint}"                                                 
};
```

<!-- ################################################################ -->
<!-- CREATE createNewPipeline -->
<!-- ################################################################ -->

<p>
<h4 id="createNewPipeline">createNewPipeline</h4>
- Create a new pipeline in the repository.
</p>

<p align="justify"> 
	
```bash
$createNewPipeline $pipeline_trigger_token $project_id $project_ref
```

```bash
function createNewPipeline() {
  local pipeline_trigger_token="${1}"
  local project_id="${2}"  
  local project_ref="${3:HEAD}"

  local gitlab_endpoint=(
    "${CI_API_V4_URL}/projects/${project_id}/repository/branches"
  );

  curl                                       \
    --fail                                   \
    --silent                                 \
    --request POST                           \
    --form "token=${pipeline_trigger_token}" \
    --form "ref=${project_ref}"              \
    --url "${gitlab_endpoint}"   
};
```

<!-- ################################################################ -->
<!-- GET getSingleProject -->
<!-- ################################################################ -->

<p>
<h4 id="getSingleProject">getSingleProject</h4>
- Get a specific project. This endpoint can be accessed without authentication if the project is publicly accessible.
</p>

<p align="justify"> 
	
```bash
$getSingleProject $user_access_token $project_id
```

```bash
function getSingleProject() {
  local user_access_token="${1}"
  local project_id="${2}"  

  local gitlab_endpoint=(
    "${CI_API_V4_URL}/projects/${project_id}"
  );

  curl                                             \
    --fail                                         \
    --silent                                       \
    --header "PRIVATE-TOKEN: ${user_access_token}" \
    --request POST                                 \
    --form description="${CI_PROJECT_NAME}"        \
    --url "${gitlab_endpoint}"                                                 
};
```
</p>
