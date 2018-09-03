class Vpnc < Formula
  desc "Cisco VPN concentrator client"
  homepage "https://www.unix-ag.uni-kl.de/~massar/vpnc/"
  url "https://mirrors.ocf.berkeley.edu/debian/pool/main/v/vpnc/vpnc_0.5.3r550.orig.tar.gz"
  mirror "https://mirrors.kernel.org/debian/pool/main/v/vpnc/vpnc_0.5.3r550.orig.tar.gz"
  version "0.5.3r550"
  sha256 "a6afdd55db20e2c17b3e1ea9e3f017894111ec4ad94622644fc841c146942e71"
 

  bottle do
    cellar :any

    sha256 "f9dcd6133700d6a752a980cf1547270f03e188666db826764c087b5ce7026b4f" => :mavericks
  end

  option "with-hybrid", "Use vpnc hybrid authentication"

  deprecated_option "hybrid" => "with-hybrid"

  depends_on "pkg-config" => :build
  depends_on "libgcrypt"
  depends_on "libgpg-error"
  depends_on "gnutls"
  depends_on :tuntap
  depends_on "openssl" if build.with? "hybrid"
	
  end


  def install
    ENV.no_optimization
    ENV.deparallelize

    (var/"run/vpnc").mkpath

    inreplace ["vpnc-script", "vpnc-disconnect"] do |s|
      s.gsub! "/var/run/vpnc", "#{var}/run/vpnc"
    end

    inreplace "vpnc.8.template" do |s|
      s.gsub! "/etc/vpnc", "#{etc}/vpnc"
    end

    inreplace "Makefile" do |s|
      s.change_make_var! "PREFIX", prefix
      s.change_make_var! "ETCDIR", etc/"vpnc"

      s.gsub! /^#OPENSSL/, "OPENSSL" if build.with? "hybrid"
    end

    inreplace "config.c" do |s|
      s.gsub! "/etc/vpnc", "#{etc}/vpnc"
      s.gsub! "/var/run/vpnc", "#{var}/run/vpnc"
    end

    system "make"
    system "make", "install"
  end

  test do
    assert_match /vpnc version/, shell_output("#{sbin}/vpnc --version")
  end

__END__
