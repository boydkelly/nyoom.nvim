(import-macros {: lz-package! : vim-pack-spec!} :macros)

(lz-package! "https://codeberg.org/esensar/nvim-dev-container"
              {:after tools.docker
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
