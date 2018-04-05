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
    prod: {
      analytics: {
        domain: 'https://bat-analytics.prod.cloudhub.io'
      },
      artifacts: {
        domain: 'https://bat-artifacts.prod.cloudhub.io'
      },
      analytics: {
        domain: 'https://bat-analytics.prod.cloudhub.io'
      },
      results: {
        domain: 'https://bat-results.prod.cloudhub.io'
      },
      scheduler: {
        domain: 'https://bat-scheduler.prod.cloudhub.io'
      },
      execution: {
        domain: 'https://bat-execution.prod.cloudhub.io'
      },
      cliXapi: {
        domain: 'https://bat-cli-xapi.prod.cloudhub.io'
      },
      xapi: {
        domain: 'https://bat-xapi.prod.cloudhub.io'
      },
      worker: {
        domain: 'https://bat-worker.prod.cloudhub.io'
    }
  }
}
}

fun array2obj(array: Array<Object>) =
  array reduce (item, carry = {}) -> carry ++ item

fun findVersions(service: String) = do {
  var colsDev = [
    GET `$(config.services.devx[service].domain)/v1/status` with {},
    GET `$(config.services.qax[service].domain)/v1/status` with {}
  ] map {
    td: "$($.result.response.body.version default 'Unknown')"
  }

  var colsProd = [
    GET `$(config.services.stgx[service].domain)/v1/status` with {},
    GET `$(config.services.prod[service].domain)/v1/status` with {}
  ] map {
    td: "$($.result.response.body.version default 'Unknown')"
  }
  ---

    tr: {
      td: "$(service)",
      (colsDev),
      (if (colsDev[1] == colsDev[0])

         td: "✓"

        else 

         td: "X"
      ),
      (colsProd)
    }

}
---
  html: {
    head: {
      meta @('http-equiv':"refresh", 'content':"30"): '',
      style @('type': "text/css"): `
         {
              font-family: "Trebuchet MS", 40px Arial, Helvetica, sans-serif;
              font-size: 350%;
              border-collapse: collapse;
              width: 100%;
          }

          td,  th {
              font-size: 350%;
              border: 1px solid #ddd;
              padding: 8px;
          }

          tr:nth-child(even){background-color: #f2f2f2;}

          tr:hover {background-color: #ddd;}

          th {
              padding-top: 12px;
              padding-bottom: 12px;
              text-align: left;
              background-color: #4CAF50;
              color: white;
          }       
        `
    },
    body: {
      table: {
        tr: {
          th: 
            b: 'Service',
          th: 
            b: 'Devx',
          th: 
            b: 'Qax',
          th: 
            b: '✓/X',
          th: 
            b: 'Stgx',
          th: 
            b: 'Prod'
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
