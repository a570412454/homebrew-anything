class Vpnc < Formula
  desc "Cisco VPN concentrator client"
  homepage "https://brianreiter.org/2014/12/03/i-modified-vpnc-cisco-vpn-client-to-use-os-x-user-native-tunnels/"
  url "https://github.com/breiter/vpnc/archive/0.5.3-xnu-2015-07-03.tar.gz"
  version "0.5.3-xnu-2015-07-03"
  sha256 "1419d6cf4e7c3ea5409fb6bf524f88d6b2752578b001c9ba4b68599d745f3a69"
  revision 4

  option "with-hybrid", "Use vpnc hybrid authentication"

  deprecated_option "hybrid" => "with-hybrid"

  depends_on "pkg-config" => :build
  depends_on "libgcrypt"
  depends_on "libgpg-error"
  depends_on "gnutls"
  depends_on "openssl" if build.with? "hybrid"

  def install
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
end
