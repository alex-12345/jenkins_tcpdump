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
                    rm -rf ../patches
                    mkdir -p ../patches
                    cd ../patches
                    wget https://raw.githubusercontent.com/alex-12345/jenkins_tcpdump/lab3/patches/fix_disableipv6.patch 
                    wget https://raw.githubusercontent.com/alex-12345/jenkins_tcpdump/lab3/patches/fix_ssl_build.patch
                    wget https://raw.githubusercontent.com/alex-12345/jenkins_tcpdump/lab3/patches/testlist.fix.patch
                    wget https://raw.githubusercontent.com/alex-12345/jenkins_tcpdump/lab3/patches/utilc.fix.patch
                    cd ../tcpdump
                    ls ../patches
                    '''
                }
            }
        }

        stage('Build release') {
            steps {
                dir("${env.WORKSPACE}/tcpdump") {
                    sh returnStatus: true, script: '''
                    CFLAGS="-O3" \
                    CXXFLAGS="-O3" \
                    ./configure 
                    make -j$(nproc)
                    ''' 
                }
            }
        }
        
        stage('Build debug with sanitizers and coverage via afl-g++') {
            steps {
                dir("${env.WORKSPACE}/tcpdump") {
                    sh returnStatus: true, script: '''
                    make distclean
                    git checkout tcpdump-4.5.0 -f
                    git clean -fd
                    git apply ../patches/fix_disableipv6.patch
                    git apply ../patches/fix_ssl_build.patch
                    git apply ../patches/testlist.fix.patch
                    git apply ../patches/utilc.fix.patch
                    '''
                    sh returnStatus: true, script: '''
                    export USER_BUILD_FLAGS="-fsanitize=address -fsanitize=undefined -O0 -g3 --coverage" && AFL_USE_UBSAN=1 AFL_USE_ASAN=1 CC=afl-gcc CXX=afl-g++ CFLAGS="$USER_BUILD_FLAGS" CXXFLAGS="$USER_BUILD_FLAGS" LDFLAGS="$USER_BUILD_FLAGS" ./configure
                    make -j$(nproc)
                    ''' 
                }
            }
        }

        stage('fuzzing') {
            steps {
                dir("${env.WORKSPACE}/tcpdump") {
                    sh returnStatus: true, script: '''
                    afl-cmin.bash -i tests/ -o testmin -m none -- ./tcpdump -nnr @@ 
                    ls testmin

                    AFL_I_DONT_CARE_ABOUT_MISSING_CRASHES=1 afl-fuzz -V 10 -i testmin -o tcpdumpfuzz -M "M" -- ./tcpdump -vvv -ee -nnr @@
                    AFL_I_DONT_CARE_ABOUT_MISSING_CRASHES=1 afl-fuzz -V 10 -i testmin -o tcpdumpfuzz -S "S-1" -- ./tcpdump -vvv -ee -nnr @@
                    AFL_I_DONT_CARE_ABOUT_MISSING_CRASHES=1 afl-fuzz -V 10 -i testmin -o tcpdumpfuzz -S "S-2" -- ./tcpdump -vvv -ee -nnr @@

                    # AFL_I_DONT_CARE_ABOUT_MISSING_CRASHES=1 screen -S "M-tcpdump" -d -m  afl-fuzz -i testmin -o tcpdumpfuzz -M "M" -- ./tcpdump -vvv -ee -nnr @@
                    # AFL_I_DONT_CARE_ABOUT_MISSING_CRASHES=1 screen -S "S-1-tcpdump" -d -m  afl-fuzz -i testmin -o tcpdumpfuzz -S "S-1" -- ./tcpdump -vvv -ee -nnr @@
                    # AFL_I_DONT_CARE_ABOUT_MISSING_CRASHES=1 screen -S "S-2-tcpdump" -d -m  afl-fuzz -i testmin -o tcpdumpfuzz -S "S-2" -- ./tcpdump -vvv -ee -nnr @@

                    tar cJf fuzzing_testmin.tar.xz testmin
                    tar cJf fuzzing_tcpdumpfuzz.tar.xz tcpdumpfuzz

                    '''
                    archiveArtifacts artifacts: '*fuzzing_*.tar.xz', followSymlinks: false
                }
            }
        }

        stage('get coverage') {
            steps {
                dir("${env.WORKSPACE}/tcpdump") {
                    sh '''
                    pwd
                    ls 
                    wget https://raw.githubusercontent.com/alex-12345/jenkins_tcpdump/lab3/ilustrate_output/tt.sh
                    bash tt.sh
                    #for F in $PWD/tcpdumpfuzz/M/queue/*; do ./tcpdump -vvv -ee -nnr $F || true; done
                    #// for F in $PWD/tcpdumpfuzz/S-1/queue/*; do ./tcpdump -vvv -ee -nnr $F; done
                    #// for F in $PWD/tcpdumpfuzz/S-2/queue/*; do ./tcpdump -vvv -ee -nnr $F; done

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