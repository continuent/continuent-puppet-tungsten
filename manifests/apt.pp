class tungsten::apt {
  if ($operatingsystem =~ /(?i:debian|ubuntu)/) {
    include apt
	  include apt::update

    Class["apt::update"] -> Package <| |>
  }
}