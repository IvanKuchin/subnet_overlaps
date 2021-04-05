# Subnet overlaps

Tool has been build to help two Enterprise companies to merge and avoid overlapping IP-ranges by NAT-int on several routers for redundancy. 

Reference to enterprise made due to routing table on core routers should have all prefixes in a single VRF vs service provider network where different technology may hide actual routing table (for example MPLS). For VRF-lite environment same process should repeat for each pair of merging VRF-s.

## How it works

Script is looking for CIDR-blocks that are overlaps between companies. Overlapping IP-ranges could be exact match (for example: 192.168.0.0/24 configured in both companies) or partial (for example: 10.11.12.0/24 belongs to Company A and 10.11.12.128/25 belongs to Company B). Both types of overlap will be found and reported. In addition to finding overlap script will produce NAT-statements (in Cisco notation) that must be applied on six routers to NAT overlapped prefixes do dedicated IP-ranges. Note that those dedicated ranges must be big enough to be able to contain all overlapped prefixes. 

Script is configured to look for overlaps in RFC1918 Ip-ranges. Supernets are not considered as overlaps:
- 0.0.0.0/0
- 10.0.0.0/8
- 172.16.0.0/12
- 192.168.0.0/16

Dedicated IP range for NAT taken from [RFC6598](https://tools.ietf.org/html/rfc6598): IANA-Reserved IPv4 Prefix for Shared Address Space: 100.64.0.0/10. 

**IMPORTANT**: it is strongy discouraged from using RFC6598 in your network, due to potential conflicts with future needs (incl: IPv6 migration).

## Scripts input.
Copy/paste `show ip route` from a CompanyA core router to sh_ip_route_companyA. 
Copy/paste `show ip route` from a CompanyB core router to sh_ip_route_companyB. 

> Hopefully core routers has all prefixes used in the network. Otherwise you got to glue full routing table from bits and pieces

## Scripts run.

Input files and script must be in the same directory.

`perl overlap.pl`

## Scripts output.

There will be a lot files in the same directory once script will be completed. Here are the most interesting:
- debug_step20_match_exact - shows prefixes that are exactly the same in both companies
- debug_step30_match_nonexact_companyA_to_companyB - shows prefixes from CompanyA that are partially overlap with prefixes in CompanyB
- debug_step30_match_nonexact_companyA_to_companyB - shows prefixes from CompanyB that are partially overlap with prefixes in CompanyA. (this is "virtually" the same file due to overlaps are the same, but view from the other side)
- result_nat_rtr1_companyA - NAT statements that must be configured on router1 of company A
- result_nat_rtr2_companyB - NAT statements that must be configured on router2 of company B

- debug_step35_match_nonexact_companyA_to_companyB.graphml - overlaps represented in GraphML-format. It could be visually represented in any online GraphML-viewer (for example: [yEd](https://www.yworks.com/yed-live/)).
- debug_step35_match_nonexact_companyB_to_companyA.graphml - same as a previous item but from another side.

Here is the screenshot produced by the yEd against included example.

![image](https://user-images.githubusercontent.com/26530162/113604660-939cbd80-9613-11eb-9631-a88d515898e0.png)

## Speed

Script is not optimized for speed, be patient in case of long routing tables. For example: if both companies has ~20K prefixes then script will work ~15 minutes.


## Example

Example of both files included into repository, so you can just run the script and check the output.



