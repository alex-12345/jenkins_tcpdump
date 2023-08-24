pipeline {

    agent { dockerfile true }
    
    stages {

        stage('Repo checkout'){
            steps {
                dir("${env.WORKSPACE}/tcpdump") {
                    deleteDir()
                }
                dir("${env.WORKSPACE}") {
                    sh returnStatus: true, script: '''
                    git clone https://github.com/the-tcpdump-group/tcpdump.git
                    '''
                }
                dir("${env.WORKSPACE}/tcpdump") {
                    sh returnStatus: true, script: '''
                    git checkout tcpdump-4.5.0 -f
                    '''
                }
            }
        }

        stage('Build') {
            steps {
                dir("${env.WORKSPACE}/tcpdump") {
                    sh returnStatus: true, script: '''
                    ./configure 
                    make -j$(nproc)
                    ''' 
                }
            }
        }

        stage('Build debug') {
            steps {
                dir("${env.WORKSPACE}/tcpdump") {
                    sh returnStatus: true, script: '''
                    make distclean
                    git checkout tcpdump-4.5.0 -f
                    git clean -fd
                    '''
                    sh returnStatus: true, script: '''
                    ./configure --enable-debugging
                    make -j$(nproc)
                    ''' 
                }
            }
        }
        
        stage('Build debug with sanitizers') {
            steps {
                dir("${env.WORKSPACE}/tcpdump") {
                    sh returnStatus: true, script: '''
                    make distclean
                    git checkout tcpdump-4.5.0 -f
                    git clean -fd
                    '''
                    sh returnStatus: true, script: '''
                    CC=afl-cc CXX=afl-c++ ./configure --enable-debugging
                    AFL_USE_ASAN=1 AFL_USE_UBSAN=1 make -j$(nproc)
                    ''' 
                }
            }
        }

        stage('Test with sanitizers') {
            steps {
                dir("${env.WORKSPACE}/tcpdump") {
                    sh returnStatus: true, script: '''
                    make check > sanitizers_report.txt
                    '''
                    archiveArtifacts artifacts: '*_report.*', followSymlinks: false
                }
            }
        }
        
        stage('Build with coverage') {
            steps {
                dir("${env.WORKSPACE}/tcpdump") {
                    sh returnStatus: true, script: '''
                    make distclean
                    git checkout tcpdump-4.5.0 -f
                    git clean -fd
                    '''
                    sh returnStatus: true, script: '''
                    CC=gcc CXX=g++ CFLAGS="-O0 -g3 --coverage" \
                    CXXFLAGS="-O0 -g3 --coverage" ./configure  --enable-debugging
                    make -j$(nproc)
                    ''' 
                }
            }
        }
        
        stage('Test coverage') {
            steps {
                dir("${env.WORKSPACE}/tcpdump") {
                    sh returnStatus: true, script: '''
                    make check > coverage_report.txt
                    echo "test"
                    lcov -t "tcpdump" -o tcpdump.info -c -d .
                    genhtml -o report tcpdump.info | tail -n3 > coverage_short_report.txt
                    tar cJf coverage_report.tar.xz report
                    '''
                    archiveArtifacts artifacts: '*_report.*', followSymlinks: false
                }
            }
        }



    }
}