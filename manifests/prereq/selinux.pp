class tungsten::prereq::selinux (
) {
	file { "/selinux/enforcing":
		owner => root,
		mode => 600,
		content => "0"
	}
}