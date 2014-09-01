module Networker
  def is_up? network
    %x( nmcli con status | grep "#{network}" | wc -l ).to_i == 1
  end

  def connect network
    %x( nmcli con up id "#{network}" --nowait ) unless is_up? network
    sleep 8

    $?.success?
  end

  def disconnect_from_ethernet
    ret = 1
    network = "eth0"
    if(is_up? network)
      %x( nmcli dev disconnect iface #{network} )
      ret = $?.success?
    end
    ret
  end

  def get_all_networks
    %x( nmcli c | awk -F'   ' '{if(NR!=1) print $1}').split(/\r?\n/)
  end
end