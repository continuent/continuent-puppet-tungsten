class continuent_install::oracle(
) inherits continuent_install::params {
	include continuent_install::prereq
	
	Class["continuent_install::prereq"] ->
	Anchor["continuent_install::oracle"]
}