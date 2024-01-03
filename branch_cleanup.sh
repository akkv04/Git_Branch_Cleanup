#!/bin/sh

echo -e "machine csh-bpad-wbcoci2.developer.ocp.oraclecloud.com\n\tlogin cshdevops\n\tpassword Password!2020" > $HOME/.netrc
chmod 600 $HOME/.netrc
export GIT_SSH="$HOME/ssh_wrapper"
echo $WORKSPACE
ORIGIN_URL="ssh://git@bitbucket.srv.westpac.com.au/mp-001/mp-001_obp.git"
#TARGET_URL=https://cshdevops@csh-bpad-wbcoci2.developer.ocp.oraclecloud.com/csh-bpad-wbcoci2/s/csh-bpad-wbcoci2_csh-bpad_562/scm/csh-obp-repo.git

cd $WORKSPACE
git clone ssh://git@bitbucket.srv.westpac.com.au/mp-001/mp-001_obp.git .

#echo "downloading the branch clean up list"
#echo "Downloading the delete list from the artifactory location : ${artifactory_url}"
#curl -O "${artifactory_url}"
#dos2unix ${file_name}

four_months_ago=$(date -d "4 month ago" --rfc-3339=date)
echo "four months ago is $four_months_ago"

# Get the list of remote branches
remote_branches=$(git for-each-ref --format="%(refname:short)" refs/remotes/origin/)
for branch in $remote_branches; do
  last_commit_date=$(git log -n 1 --pretty=format:"%ad" --date=short "$branch")

  # Compare the last commit date to 4 months ago
if [ "$last_commit_date" '<' "$four_months_ago"  ]; then 
      if [[ "$branch" == origin/hotfix* || "$branch" == origin/release* || "$branch" == origin/master ]]; then
              continue
                fi
    branch_name=$(echo "$branch" | sed 's#^origin/##')
    #echo "Branch $branch_name: Last commit date $last_commit_date is more than 4 months old."
    echo $branch_name >> $WORKSPACE/old_branch_list.txt
  fi
done

echo "branches to be deleted"
cat $WORKSPACE/old_branch_list.txt
echo "_________________________________"

if [ -s  $WORKSPACE/old_branch_list.txt ]
then
              #DEFAULT_REPO_LIST="$ORIGIN_URL $TARGET_URL"
              #REPO_LIST=$DEFAULT_REPO_LIST
              #for REPO in $REPO_LIST; do
              REPO=$ORIGIN_URL
                             echo "setting remote name as  $REPO"
                             git remote set-url origin $REPO
              git remote -v
    
                             while IFS= read -r line;do
                             echo "Deleting $line"
            echo "git push origin --delete $line"
              git push origin --delete $line
                             done < $WORKSPACE/old_branch_list.txt
    
              #done   

              #echo "Updating the workspace for repo sync"
              #cd /oracle/stage/installable/slave/workspace/MP-001_CSH/OBP-Build-Packaging/CSH_OBP_REPOSYNC/mp-001_obp
              #git pull
else
             echo "No  branches detected older than 4 months"
    echo "*****************************************"
fi
