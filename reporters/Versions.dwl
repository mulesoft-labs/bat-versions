%dw 2.0

output application/xml  
import * from bat::BDD

var config = {
  services: {
    devx: {
      analytics: {
        domain: 'https://bat-analytics.devx.msap.io'
      },
      artifacts: {
        domain: 'https://bat-artifacts.devx.msap.io'
      },
      results: {
        domain: 'https://bat-results.devx.msap.io'
      },
      scheduler: {
        domain: 'https://bat-scheduler.devx.msap.io'
      },
      execution: {
        domain: 'https://bat-execution.devx.msap.io'
      },
      cliXapi: {
        domain: 'https://bat-cli-xapi.devx.msap.io'
      },
      xapi: {
        domain: 'https://bat-xapi.devx.msap.io'
      },
      worker: {
        domain: 'https://bat-worker.devx.msap.io'
      }
    },
    qax: {
      analytics: {
        domain: 'https://bat-analytics.qax.msap.io'
      },
      artifacts: {
        domain: 'https://bat-artifacts.qax.msap.io'
      },
      results: {
        domain: 'https://bat-results.qax.msap.io'
      },
      scheduler: {
        domain: 'https://bat-scheduler.qax.msap.io'
      },
      execution: {
        domain: 'https://bat-execution.qax.msap.io'
      },
      cliXapi: {
        domain: 'https://bat-cli-xapi.qax.msap.io'
      },
      xapi: {
        domain: 'https://bat-xapi.qax.msap.io'
      },
      worker: {
        domain: 'https://bat-worker.qax.msap.io'
      }
    },
    stgx: {
      analytics: {
        domain: 'https://bat-analytics.stgx.msap.io'
      },
      artifacts: {
        domain: 'https://bat-artifacts.stgx.msap.io'
      },
      analytics: {
        domain: 'https://bat-analytics.stgx.msap.io'
      },
      results: {
        domain: 'https://bat-results.stgx.msap.io'
      },
      scheduler: {
        domain: 'https://bat-scheduler.stgx.msap.io'
      },
      execution: {
        domain: 'https://bat-execution.stgx.msap.io'
      },
      cliXapi: {
        domain: 'https://bat-cli-xapi.stgx.msap.io'
      },
      xapi: {
        domain: 'https://bat-xapi.stgx.msap.io'
      },
      worker: {
        domain: 'https://bat-worker.stgx.msap.io'
      }
    },
    jenkins: {
      analytics: {
        domain: 'https://jenkins-0.prod.build.msap.io/job/BAT%20(API%20Testing)/job/bat-analytics-service/job/master/api/json?pretty=true'
      },
      artifacts: {
        domain: 'https://jenkins.build.msap.io/job/BAT%20(API%20Testing)/job/bat-asset-provider/job/master/api/json?pretty=true'
      },
      results: {
        domain: 'https://jenkins.build.msap.io/job/BAT%20(API%20Testing)/job/bat-asset-provider/job/master/api/json?pretty=true'
      },
      scheduler: {
        domain: 'https://jenkins.build.msap.io/job/BAT%20(API%20Testing)/job/bat-scheduler-service/job/master/api/json?pretty=true'
      },
      execution: {
        domain: 'https://jenkins.build.msap.io/job/BAT%20(API%20Testing)/job/bat-execution-service/job/master/api/json?pretty=true'
      },
      cliXapi: {
        domain: 'https://jenkins.build.msap.io/job/BAT%20(API%20Testing)/job/bat-cli-xapi/job/master/api/json?pretty=true'
      },
      xapi: {
        domain: 'https://jenkins.build.msap.io/job/BAT%20(API%20Testing)/job/bat-xapi/job/master/api/json?pretty=true'
      },
      worker: {
        domain: 'https://jenkins.build.msap.io/job/BAT%20(API%20Testing)/job/bat-worker-service/job/master/api/json?pretty=true'
      }
    }
  }
}

fun array2obj(array: Array<Object>) =
    array reduce (item, carry = {}) ->
        carry ++ item

fun findVersions(service: String) = do {
    var cols = [
        GET `$(config.services.devx[service].domain)/v1/status` with {},
        GET `$(config.services.qax[service].domain)/v1/status` with {},
        GET `$(config.services.stgx[service].domain)/v1/status` with {}
    ] map {
        td: "$($.result.response.body.version default 'Unknown')"
    }
    var jenkinsVersion = [
      GET `$(config.services.jenkins[service].domain)` with {
          headers: {
            Authorization: "Basic ZmVybmFuZG8uZmVycmFyYXp6bzpNdWxlMTIzNGZlcg=="
          }
        }
    ] map {
      td: $.result.response.body.lastCompletedBuild.number 
    }
    ---
    tr: {
        td: "$(service)",
        (cols),
        (jenkinsVersion)
    }
}
---
html: {
  head: {},
  body: {
    h1: 'Services',
    table: {
      tr: {
        th: 
          b: 'Service',
        th: 
          b: 'Devx',
        th: 
          b: 'Qax',
        th: 
          b: 'Stgx',
        th: 
          b: 'Jenkins'
      },
      (findVersions('analytics')),
      (findVersions('artifacts')),
      (findVersions('results')),
      (findVersions('cliXapi')),
      (findVersions('execution')),
      (findVersions('scheduler')),
      (findVersions('worker')),
      (findVersions('xapi'))
    }
  }
}
