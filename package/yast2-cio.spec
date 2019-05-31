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

# Please submit bugfixes or comments via https://bugs.opensuse.org/
#


######################################################################
#
# IMPORTANT: Please do not change spec file in build service directly
#            Use https://github.com/yast/yast-cio repo
#
######################################################################

Name:           yast2-cio
Version:        4.1.0
Release:        0
Summary:        YaST2 - IO Channel management
Group:          System/YaST
License:        GPL-2.0-only or GPL-3.0-only
Url:            https://github.com/yast/yast-cio

Source0:        %{name}-%{version}.tar.bz2

BuildRequires:  update-desktop-files
BuildRequires:  yast2-ruby-bindings >= 1.2.0
BuildRequires:  yast2-devtools >= 1.2.0
BuildRequires:  yast2 >= 3.0.5
#for install task
BuildRequires:  rubygem(yast-rake)
# for tests
BuildRequires:  rubygem(rspec)

Requires:       yast2 >= 3.0.5
Requires:       yast2-ruby-bindings >= 1.2.0
Requires:       s390-tools

ExclusiveArch:  s390 s390x

%description
Provides interface for blacklisting and unblocking IO channels

%prep
%setup -q

%check
%yast_check

%install
%yast_install
%yast_metainfo

%files
%{yast_clientdir}
%{yast_libdir}
%{yast_desktopdir}
%{yast_metainfodir}
%{yast_icondir}
%doc README.md
%license COPYING
