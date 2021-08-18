#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'dotenv'
require 'gitlab'

Dotenv.load

# TODO: authenticate with github (or do this in the github action, and just check it here)

Gitlab.configure do |config|
    config.endpoint       =  ENV['GITLAB_API_ENDPOINT']
    config.private_token  =  ENV['GITLAB_API_PRIVATE_TOKEN']
end

def github_repo_exists?(project)
    system("git ls-remote -q git@github.com:dxw-wordpress-plugins/#{project.name}.git >/dev/null 2>&1")
end

def gitlab_project_empty?(project)
    gitlab_commits = Gitlab.commits(project.id, per_page: 1)
    gitlab_commits.empty?
end

def repos_in_sync?(project)
    github_latest_commit_hash = `gh api repos/dxw-wordpress-plugins/#{project.name}/commits/main -q '.sha'`
    gitlab_commits = Gitlab.commits(project.id, per_page: 1)
    gitlab_latest_commit_hash = gitlab_commits[0].id
    github_latest_commit_hash.strip == gitlab_latest_commit_hash.strip
end

def mirror_gitlab_repo(project, create = false)
    puts "Cloning the gitlab source..."
    # clone the gitlab repo
    `git clone --mirror #{project.ssh_url_to_repo}`
    # We can't give the remote a different name with mirror, so remove it
    `git -C #{project.name}.git remote remove origin`
    if (create)
        puts "Creating the github repo..."
        `gh repo create dxw-wordpress-plugins/#{project.name} --private --team govpress-team -y`
    end
    puts "Updating the github repo..."
    # mirror push upstream    
    `git -C #{project.name}.git push --mirror git@github.com:dxw-wordpress-plugins/#{project.name}.git`
    # clean up
    `rm -rf #{project.name}.git` 
end

projects = Gitlab.group_projects(ENV['GITLAB_WORDPRESS_PLUGINS_GROUP_ID'], per_page: 2)

projects.each do |project|
    puts "Checking status of #{project.name}..."
    # check if the repo already exists on github
    if (github_repo_exists?(project))
        puts "#{project.name} repo already exists"    
        if (gitlab_project_empty?(project))
            puts "...but source repo is empty"
            next project
        end
        if (repos_in_sync?(project))
            puts "...and is in sync"
            next project
        end
        puts "... mirroring to it now"
        mirror_gitlab_repo(project)
    else
        # if it doesn't, create it
        # and add the govpress team to it
        puts "#{project.name} repo does not exist"
        if (gitlab_project_empty?(project))
            puts "...but source repo is empty"
            next project
        end
        puts "...creating and mirroring to it now"
        mirror_gitlab_repo(project, true)    
    end

end







