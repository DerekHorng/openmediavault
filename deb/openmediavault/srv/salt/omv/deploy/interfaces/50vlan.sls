# This file is part of OpenMediaVault.
#
# @license   http://www.gnu.org/licenses/gpl.html GPL Version 3
# @author    Volker Theile <volker.theile@openmediavault.org>
# @copyright Copyright (c) 2009-2018 Volker Theile
#
# OpenMediaVault is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# any later version.
#
# OpenMediaVault is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with OpenMediaVault. If not, see <http://www.gnu.org/licenses/>.

# Documentation/Howto:
# https://wiki.archlinux.org/index.php/Systemd-networkd
# http://enricorossi.org/blog/2017/systemd_network_vlan_interface_up/

{% set interfaces = salt['omv.get_config_by_filter'](
  'conf.system.network.interface',
  {'operator': 'stringEquals', 'arg0': 'type', 'arg1': 'vlan'}) %}

{% for interface in interfaces %}

configure_interface_vlan_{{ interface.vlanrawdevice }}.{{ interface.vlanid }}_netdev:
  file.managed:
    - name: "/etc/systemd/network/openmediavault-{{ interface.vlanrawdevice }}.{{ interface.vlanid }}.netdev"
    - source:
      - salt://{{ slspath }}/files/vlan_netdev.j2
    - template: jinja
    - context:
        interface: {{ interface | json }}
    - user: root
    - group: root
    - mode: 644

configure_interface_vlan_{{ interface.vlanrawdevice }}.{{ interface.vlanid }}_network:
  file.managed:
    - name: "/etc/systemd/network/openmediavault-{{ interface.vlanrawdevice }}.{{ interface.vlanid }}.network"
    - source:
      - salt://{{ slspath }}/files/vlan_network.j2
    - template: jinja
    - context:
        interface: {{ interface | json }}
    - user: root
    - group: root
    - mode: 644

configure_interface_vlan_{{ interface.vlanrawdevice }}_network:
  file.touch:
    - name: "/etc/systemd/network/openmediavault-{{ interface.vlanrawdevice }}.network"
  ini.options_present:
    - name: "/etc/systemd/network/openmediavault-{{ interface.vlanrawdevice }}.network"
    - separator: "="
    - sections:
        Network:
          VLAN: {{ interface.vlanrawdevice }}.{{ interface.vlanid }}

{% endfor %}
