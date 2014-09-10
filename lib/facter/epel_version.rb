# epel_version.rb
# A facter fact to determine the epel version

Facter.add('epel_version') do
  setcode do
    Facter::Util::Resolution.exec("rpm -qa | grep epel-release | awk -F- '{print $3}'")
  end
end
