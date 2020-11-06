def multiline(text)
    <<-END.gsub(/^\s+\|/, '')
    #{text}
    END
end

jdk_version = ENV['JDK_VERSION'] || fail('JDK_VERSION environment variable unset')
jdk_type = ENV['JDK_TYPE']
image_name = "adoptopenjdk/#{jdk_version}-jdk-#{jdk_type}"
from = "FROM #{image_name}"
os = ENV["OS"] || fail("OS environment variable unset")
prepare =
    if os.start_with?("windows") then
        install_choco = 
            'Set-ExecutionPolicy Bypass -Scope Process -Force;'\
            '[System.Net.ServicePointManager]::SecurityProtocol = '\
            '[System.Net.ServicePointManager]::SecurityProtocol -bor 3072; '\
            'iex ((New-Object System.Net.WebClient).DownloadString('\
            "'https://chocolatey.org/install.ps1'))"
        install_git = 'choco install git'
        [install_choco, install_git]
    else
        ['apt-get update', 'apt-get install git']
    end
prepare = prepare.map { |it| "RUN #{it}" }.join("\n")
dockerfile = multiline(%{
    |#{from}
    |#{prepare}
    |ENV TERM='dumb'
    |CMD java -version
})
File.write("Dockerfile", dockerfile)
