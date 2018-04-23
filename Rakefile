# Copyright (c) 2014 SUSE LLC.
#  All Rights Reserved.

#  This program is free software; you can redistribute it and/or
#  modify it under the terms of version 2 or 3 of the GNU General
# Public License as published by the Free Software Foundation.

#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.   See the
#  GNU General Public License for more details.

#  You should have received a copy of the GNU General Public License
#  along with this program; if not, contact SUSE LLC.

#  To contact Novell about this file by physical or electronic mail,
#  you may find current contact information at www.suse.com

require "yast/rake"

Yast::Tasks.submit_to :sle15

# do nothing in osc:build as it can be built exclusively on s390
Rake::Task["osc:build"].clear_actions if `uname --machine` !~ /s390/

Yast::Tasks.configuration do |conf|
  conf.skip_license_check << /lscss.output.*/
  # desktop files are just metadata
  conf.skip_license_check << /.*desktop$/
end
