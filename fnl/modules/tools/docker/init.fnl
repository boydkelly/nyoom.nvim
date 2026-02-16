(import-macros {: lz-package! : build-pack-table : build-before-all-hook} :macros)

(lz-package! "https://codeberg.org/esensar/nvim-dev-container"
              {:nyoom-module tools.docker
               :cmd [:DevcontainerBuild
                     :DevcontainerImageRun
                     :DevcontainerBuildAndRun
                     :DevcontainerBuildRunAndAttach
                     :DevcontainerComposeUp
                     :DevcontainerComposeDown
                     :DevcontainerComposeRm
                     :DevcontainerStartAuto
                     :DevcontainerStartAutoAndAttach
                     :DevcontainerAttachAuto
                     :DevcontainerStopAuto
                     :DevcontainerStopAll
                     :DevcontainerRemoveAll
                     :DevcontainerLogs
                     :DevcontainerOpenNearestConfig
                     :DevcontainerEditNearestConfig]})
