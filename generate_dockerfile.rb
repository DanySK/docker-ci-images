def multiline(text)
    <<-END.gsub(/^\s+\|/, '')
    #{text}
    END
end

jdk_version = ENV['JDK_VERSION'] || fail('JDK_VERSION environment variable unset')
jdk_type = ENV['JDK_TYPE'] || fail('JDK_TYPE environment variable unset')
image_name = jdk_version.empty? ? jdk_type : "#{jdk_version}-jdk-#{jdk_type}"
from = "FROM adoptopenjdk:#{image_name}"
os = ENV["OS"] || fail("OS environment variable unset")
prepare =
    if os.start_with?("windows") then
        install_choco = 
            'Set-ExecutionPolicy Bypass -Scope Process -Force;'\
            '[System.Net.ServicePointManager]::SecurityProtocol = '\
            '[System.Net.ServicePointManager]::SecurityProtocol -bor 3072; '\
            'iex ((New-Object System.Net.WebClient).DownloadString('\
            "'https://chocolatey.org/install.ps1'))"
        install_git = 'choco install git --no-progress'
        [install_choco, install_git]
    else
        ['apt-get update', 'apt-get --no-install-recommends install git -y']
    end
prepare = prepare.map { |it| "RUN #{it}" }.join("\n")
dockerfile = multiline(%{
    |#{from}
    |#{prepare}
    |ENV TERM='dumb'
    |CMD java -version
})
File.write("Dockerfile", dockerfile)
