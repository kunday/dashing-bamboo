require 'net/http'
require 'json'
require 'time'

BAMBOO_URI = "URI"

builds = ["Plan Keys"]

class BambooBuild
  def initialize(base_uri)
    @uri = base_uri
  end
  
  def build_status(job_key)
    uri = URI.parse(@uri)
    http = Net::HTTP.new(uri.host, uri.port)
    puts result_endpoint(job_key)
    response = http.request(Net::HTTP::Get.new(result_endpoint(job_key)))
    response_json = JSON.parse(response.body)
    latest_run = response_json["results"]["result"][0]
    build_info = {
      :status => latest_run["lifeCycleState"],
      :start => latest_run["prettyBuildStartedTime"],
      :end => latest_run["prettyBuildCompletedTime"],
      :duration => latest_run["buildDurationDescription"],
      :finished => latest_run["buildRelativeTime"],
      :reason => latest_run["buildReason"],
      :state => latest_run["state"],
      :number => latest_run["number"]
    }
  end
  
  private
  def rest_endpoint
    "/rest/api/latest"
  end
  
  def result_endpoint(job_key)
    "#{rest_endpoint}/result/#{job_key}.json?expand=results.result&max-results=1"
  end
end

def get_total_queued_builds(job_name)
end

def get_build_status(job)
  build = BambooBuild.new(BAMBOO_URI)
  build.build_status(job)
end

builds.each do |build|
  SCHEDULER.every '10s', :first_in => 0 do |job|
    status = get_build_status(build)
    send_event(build, status)
  end
end
