# require 'enzyme'
# require 'json'
# require 'typhoeus'
# require 'time'
#
# module Issues extend self
#
#   def run(user=nil)
#     ARGV.reject { |x| x.start_with?("-") }
#     project = ARGV.shift
#     milestone = ARGV.shift
#
#     @cache = {}
#
#     if project
#       if milestone
#         # whatever
#       else
#         # whatever
#       end
#     else
#       all_milestones = []
#       repos_with_issues = repos.select { |repo| repo['open_issues'] > 0 }
#
#       repos_with_issues.each do |repo|
#         m = milestones(repo['name'])
#
#         m.collect! do |milestone|
#           your_issues = issues(repo['name'], :state => 'open', :assignee => $settings.github.user, :milestone => milestone['number'])
#           milestone.merge({ 'repo' => repo['name'], 'assigned_issues' => your_issues.count })
#         end
#
#         all_milestones.concat(m)
#       end
#
#       all_milestones.sort! do |a,b|
#         if a['due_on'].nil? || b['due_on'].nil?
#           a['due_on'].nil? ? 1 : -1
#         else
#           a['due_on'] <=> b['due_on']
#         end
#       end
#
#       all_milestones.each do |milestone|
#         puts "#{$format.bold}%-20s#{$format.normal}%-20s%-20s#{$format.bold}%2d#{$format.normal} open issues (#{$format.bold}%d#{$format.normal} assigned to you)" % [
#           human_due_date(milestone['due_on']),
#           milestone['repo'],
#           milestone['title'],
#           milestone['open_issues'],
#           milestone['assigned_issues']
#         ]
#       end
#     end
#
#     puts
#
#   end
#
#   def human_due_date(date)
#     if milestone['due_on']
#       Time.iso8601(milestone['due_on']).strftime('%d %b %Y')
#     else
#       "Not Scheduled"
#     end
#   end
#
#   def issues(repo, params={})
#     get("https://api.github.com/repos/#{$settings.github.organisation}/#{repo}/issues", { :per_page => 100 }.merge(params))
#   end
#
#   def milestones(repo)
#     get("https://api.github.com/repos/#{$settings.github.organisation}/#{repo}/milestones")
#   end
#
#   def repos
#     get("https://api.github.com/orgs/#{$settings.github.organisation}/repos")
#   end
#
#   def get(url, params={})
#     cache_id = "GET #{url}" # Hash[params.sort].to_s
#
#     # unless @cache[cache_id]
#       response = Typhoeus::Request.get(url, :username => $settings.github.user, :password => $settings.github.password, :params => params)
#       if response.success?
#         @cache[cache_id] = JSON.parse(response.body)
#       elsif response.timed_out?
#         # aw hell no
#         raise "got a time out"
#       elsif response.code == 0
#         # Could not get an http response, something's wrong.
#         raise response.curl_error_message
#       else
#         # Received a non-successful http response.
#         raise "HTTP request failed: #{response.code.to_s}"
#       end
#     # end
#
#     @cache[cache_id]
#   end
#
# end

# Enzyme.register(Issues) do
#   puts "#{$format.bold}SYNOPSIS#{$format.normal}"
#   puts '     enzyme issues [<project> [<milestone>]]'
#   puts
#   puts "#{$format.bold}EXAMPLES#{$format.normal}"
#   puts "     enzyme issues abc # Lists all your issues for the 'abc' project."
#   puts
# end


# enzyme issues
#
# **12 June 2011**
# koi_cms            0.2.1              **25** open issues (**6** assigned to you)
# koi_cms            0.2.2              **6** open issues (**1** assigned to you)
#
# **25 June 2011**
# koi_cms            0.2.3              **11** open issues
#
# **Not Scheduled**
# koi_cms            2.0.0              **13** open issues (**6** assigned to you)
# koi_cms            <no milestone>     **44** open issues
#