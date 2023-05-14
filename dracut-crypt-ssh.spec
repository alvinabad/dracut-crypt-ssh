Name:           %{name}
Version:        %{version}
Release:        %{release}%{?dist}
Summary:        %{summary}
Source0:        %{name}-%{version}.tar.gz
License:        %{license}
URL:            %{url}

BuildRequires:  gcc libblkid-devel
Requires:       dracut dracut-network dropbear

%description
%{desc}

%global debug_package %{nil} 

%prep
%setup

%build
./configure
make
make DESTDIR=%{_topdir}/INSTALL install

%install
cp -a %{_topdir}/INSTALL/. %{buildroot}/

%files
%attr(-,root,-) /usr/lib/dracut/modules.d/60crypt-ssh
%config %attr(-,root,-) /etc/dracut.conf.d/crypt-ssh.conf
