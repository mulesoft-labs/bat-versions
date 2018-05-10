def jenkinsSteps() {
  wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'XTerm']) {
    def config, repoConfig = null
    def isFromPipeline = false
    def isCron = false
    def slack_channel = null

    env.NEW_RELIC_LICENSE_KEY = "9f0a6178a6d1a522e55b02142a005e14bbb16868"
    env.WRAPPER_VERSION = "1.0.56"


    // _collector=Automation _source=bat
    // https://service.us2.sumologic.com/ui/bento.html#/search/273e0cde_fdff_027a_8c8d_b0a96fd1ec56
    env.SUMO_ENDPOINT = "https://endpoint1.collection.us2.sumologic.com/receiver/v1/http/ZaVnC4dhaV3eRt9ER7Y9fYt_hkF0R_UzN6XsNPpWpob0lWMknNVeqA0augmB04Z10cKVKJzwiMyRLBtpieLAmP9DmGTSstkSMKi5unzx4d73OUGcgbDlJQ=="

    if (env.PIPELINE_ENV == null || env.PIPELINE_ENV == 'null' || env.PIPELINE_ENV == '') {
      if (env.ENV == null || env.ENV == 'null') {
        env.ENV = 'default'
      }
    } else {
      if(env.ENV == "cron"){
        isCron = true;
      } else {
        isFromPipeline = true
      }
      env.ENV = env.PIPELINE_ENV
    }

    if (env.TEST_FILE == null || env.TEST_FILE == 'null') {
      env.TEST_FILE = ''
    } else {
      env.TEST_FILE = env.TEST_FILE + ' '
    }

    currentBuild.displayName = currentBuild.displayName ?: "#${env.BUILD_NUMBER}"
    currentBuild.displayName = currentBuild.displayName + " (${env.ENV})"

    if (isFromPipeline) {
      currentBuild.displayName = "#${env.BUILD_NUMBER} Pipeline (${env.ENV})"
    } else if (isCron) {
      currentBuild.displayName = "#${env.BUILD_NUMBER} Cron (${env.ENV})"
    }

    stage('Initialization') {
      echo "Cause: ${env.BUILD_CAUSE}"

      config = readYaml file: 'config/defaults.yaml'

      // download the latest version of bat-wrapper
      sh("wget https://repository-master.mulesoft.org/nexus/content/repositories/releases/com/mulesoft/bat/bat-wrapper/${env.WRAPPER_VERSION}/bat-wrapper-${env.WRAPPER_VERSION}.zip -O .batWrapper")

      // unzip bat wrapper
      sh("unzip -o .batWrapper")

      env.PATH = "${tool 'Java 8'}/bin:${env.PATH}"

      sh "./bat/bin/bat --update"

      env.JUNIT_REPORT_PATH = "TEST-${env.BUILD_TAG}-JUnit.xml"
      env.HTML_REPORT_PATH = "TEST-${env.BUILD_TAG}-HTML.html"
      env.JSON_REPORT_PATH = "TEST-${env.BUILD_TAG}-BAT.json"
      env.NEW_RELIC_REPORT_PATH = "TEST-${env.BUILD_TAG}-NewRelic.json"
      env.SUMO_LOGIC_REPORT_PATH = "TEST-${env.BUILD_TAG}-SumoLogic.json"
    }

    stage('Checkout') {
      dir(config.sourceFolder) {
        checkout scm
        try {
          repoConfig = readYaml file: 'bat.yaml'
        } catch(Exception e) {
          try {
            repoConfig = readYaml file: 'bat.yml'
          } catch(Exception ex) {
            echo 'Cannot find file bat.yaml'
          }
        }

        def triggers = []

        try {
          if (repoConfig != null) {
            if (env.BRANCH_NAME == "master") {
              def suiteTriggers = repoConfig.suite.triggers

              for (int index = 0; index < suiteTriggers.size(); index++) {
                def suiteTrigger = suiteTriggers[index]
                if (suiteTrigger.cron) {
                  triggers << cron(suiteTrigger.cron)

                  echo "Will shedule a cron ${suiteTrigger.cron}"
                }
              }
            }
          }
        } catch(e) {
          echo e.toString()
        }

        properties([
          parameters([
            string(name: 'ENV', description: 'Which environment will be used for configurations', defaultValue: 'default'),
            string(name: 'TEST_FILE', description: 'The file to be executed by BAT. By default it will search main.yml, main.yaml, main.dwl, test.dwl', defaultValue: ''),
            string(name: 'PIPELINE_ENV', description: 'Same as ENV, used from CD pipelines. Keep blank if you use ENV.', defaultValue: '')
          ]),
          pipelineTriggers(triggers),
          buildDiscarder(logRotator(artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '', numToKeepStr: '100'))
        ])
      }
    }

    try {
      slack_channel = config.slackChannel
      slack_channel = repoConfig.metadata.slack_channel
    } catch(error) { }

    stage('Run tests') {
      dir(config.sourceFolder) {
        def pipelineLabel = ""

        if (isFromPipeline){
          pipelineLabel = "(From Pipeline)"
        }

        def slackMessage = "Job `${env.JOB_NAME}` *<${env.BUILD_URL}console|#${env.BUILD_NUMBER} View console> (${env.ENV})*"

        try {
          slackSend channel: "#${slack_channel}", message: "${slackMessage} is starting ${pipelineLabel}"

          timeout(time: 10, unit: 'MINUTES') {
            sh "../bat/bin/bat ${env.TEST_FILE}\"-R=bat/Reporters/JUnit.dwl:${env.JUNIT_REPORT_PATH}\" \"-R=bat/Reporters/JSON.dwl:${env.JSON_REPORT_PATH}\" \"-R=bat/Reporters/HTML.dwl:${env.HTML_REPORT_PATH}\" \"-R=bat/Reporters/NewRelic.dwl:${env.NEW_RELIC_REPORT_PATH}\" \"-R=bat/Reporters/SumoLogic.dwl:${env.SUMO_LOGIC_REPORT_PATH}\" --env=${env.ENV} --debug --stack"
          }

          slackSend color: 'good', channel: "#${slack_channel}", message: ":white_check_mark: ${slackMessage} succeed. <${env.BUILD_URL}BAT_Report/|View report> ${pipelineLabel}"
        } catch(error) {
          slackSend color: '#ff0000', channel: "#${slack_channel}", message: ":bangbang: ${slackMessage} failed. <${env.BUILD_URL}BAT_Report/|View report> ${pipelineLabel}"
          throw error
        } finally {
          step([
              $class           : 'JUnitResultArchiver',
              allowEmptyResults: true,
              testResults      : env.JUNIT_REPORT_PATH
          ])

          publishHTML([
            allowMissing         : true,
            alwaysLinkToLastBuild: false,
            keepAll              : true,
            reportDir            : '.',
            reportFiles          : env.HTML_REPORT_PATH,
            reportName           : "BAT Report"
          ])

          archive env.JUNIT_REPORT_PATH
          archive env.JSON_REPORT_PATH
          archive env.HTML_REPORT_PATH
          archive env.NEW_RELIC_REPORT_PATH
          archive env.SUMO_LOGIC_REPORT_PATH

          if (repoConfig != null) {
            if(repoConfig.reporters != null){
              def reporters = repoConfig.reporters
              for (int i = 0; i < reporters.size(); i++) {
                if(reporters[i].outFile != null){
                  echo 'Uploading ' + reporters[i].outFile
                  archive reporters[i].outFile
                }
              }
            }
          }
        }
      }
    }
  }
}

return this
