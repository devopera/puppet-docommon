require 'yaml'

# load all custom facts from client's local /etc/puppet/
if File.exist?("/etc/puppet/custom_facts.yml")
  YAML.load_file("/etc/puppet/custom_facts.yml").each do |key, value|
    Facter.add(key.to_sym) do
      setcode { value }
    end
  end
end

# create a fact for gathering the puppetmaster IP from the hosts file
Facter.add("puppetmaster_ipaddress") do
  setcode "cat /etc/hosts | grep '[0-9][a-z\. ]*puppet' | gawk -F' ' '{print $1}'"
end

# create a fact for gathering the puppetmaster name from the puppet.conf file
Facter.add("puppetmaster_directive_name") do
  setcode "cat /etc/puppet/puppet.conf | grep 'server = ' | sed -e 's/[ server]*=[ ]*//g'"
end

