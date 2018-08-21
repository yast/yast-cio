#
# spec file for package yast2-services-manager
#
# Copyright (c) 2013 SUSE LINUX Products GmbH, Nuernberg, Germany.
#
# All modifications and additions to the file contributed by third parties
# remain the property of their copyright owners, unless otherwise agreed
# upon. The license for this file, and modifications and additions to the
# file, is the same license as for the pristine package itself (unless the
# license for the pristine package is not an Open Source License, in which
# case the license is the MIT License). An "Open Source License" is a
# license that conforms to the Open Source Definition (Version 1.9)
# published by the Open Source Initiative.

# Please submit bugfixes or comments via http://bugs.opensuse.org/
#


######################################################################
#
# IMPORTANT: Please do not change spec file in build service directly
#            Use https://github.com/yast/yast-cio repo
#
######################################################################

Name:           yast2-cio
Version:        4.0.3
Release:        0
ExclusiveArch:  s390 s390x

BuildRoot:      %{_tmppath}/%{name}-build
Source0:        %{name}-%{version}.tar.bz2

Requires:       yast2 >= 3.0.5
Requires:       yast2-ruby-bindings >= 1.2.0
Requires:       s390-tools

BuildRequires:  update-desktop-files
BuildRequires:  yast2-ruby-bindings >= 1.2.0
BuildRequires:  yast2-devtools >= 1.2.0
BuildRequires:  yast2 >= 3.0.5
#for install task
BuildRequires:  rubygem(yast-rake)
# for tests
BuildRequires:  rubygem(rspec)

Summary:        YaST2 - IO Channel management
Group:          System/YaST
License:        GPL-2.0 or GPL-3.0
Url:            https://github.com/yast/yast-cio

%description
Provides interface for blacklisting and unblocking IO channels

%prep
%setup -n %{name}-%{version}

%check
rake test:unit

%install
rake install DESTDIR="%{buildroot}"

# Remove the license from the /usr/share/doc/packages directory,
# it is also included in the /usr/share/licenses directory by using
# the %license tag.
rm -f $RPM_BUILD_ROOT/%{yast_docdir}/COPYING

%files
%defattr(-,root,root)
%{yast_dir}/clients/*.rb
%{yast_dir}/lib/iochannel
%{yast_desktopdir}/cio.desktop

%doc README.md
%license COPYING
