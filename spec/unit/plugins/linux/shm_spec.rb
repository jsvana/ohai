#
# Author:: Jay Vana <jsvana@fb.com>
# Copyright:: Copyright (c) 2016 Facebook
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require File.expand_path(File.dirname(__FILE__) + "/../../../spec_helper.rb")

describe Ohai::System, "Linux shared memory segments plugin" do
  let(:plugin) { get_plugin("linux/shm") }

  before(:each) do
    allow(plugin).to receive(:collect_os).and_return(:linux)
  end

  it "should populate shm if ipcs is found" do
    ipcs_out = <<-IPCS_OUT

------ Shared Memory Segments --------
key        shmid      owner      perms      bytes      nattch     status
0x00000000 196608     jsvana     600        393216     2          dest
0x0056a4d5 32276485   jsvana     660        488        1
0x0056a4d6 32309254   jsvana     660        131072     1

IPCS_OUT
    allow(plugin).to receive(:which).with("ipcs").and_return("/usr/bin/ipcs")
    allow(plugin).to receive(:shell_out).with("/usr/bin/ipcs -m").and_return(mock_shell_out(0, ipcs_out, ""))
    plugin.run
    expect(plugin[:shm].to_hash).to eq({
      196608 => {
        "key"    => "0x00000000",
        "owner"  => "jsvana",
        "perms"  => "600",
        "bytes"  => 393216,
        "nattch" => 2,
        "status" => "dest",
      },
      32276485 => {
        "key"    => "0x0056a4d5",
        "owner"  => "jsvana",
        "perms"  => "660",
        "bytes"  => 488,
        "nattch" => 1,
        "status" => "",
      },
      32309254 => {
        "key"    => "0x0056a4d6",
        "owner"  => "jsvana",
        "perms"  => "660",
        "bytes"  => 131072,
        "nattch" => 1,
        "status" => "",
      },
    })
  end

  it "should not populate shm if ipcs is not found" do
    allow(plugin).to receive(:which).with("ipcs").and_return(false)
    plugin.run
    expect(plugin[:shm]).to be(nil)
  end
end
