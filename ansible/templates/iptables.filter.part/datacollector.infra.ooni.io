{% extends 'iptables.filter.part' %}

{% block chain %}
:NFS -
{% endblock %}

{% block svc %}
# http & https to export measurements
-A INPUT -p tcp -m tcp --dport 80 --tcp-flags FIN,SYN,RST,ACK SYN -j ACCEPT
-A INPUT -p tcp -m tcp --dport 443 --tcp-flags FIN,SYN,RST,ACK SYN -j ACCEPT

# NFS for workers
-A INPUT -p udp -m udp --dport 111 -j NFS
-A INPUT -p tcp -m tcp --dport 111 -j NFS
-A INPUT -p udp -m udp --dport 2049:2051 -j NFS
-A INPUT -p tcp -m tcp --dport 2049:2051 -j NFS
# -A NFS -s 2.4.6.8 -j ACCEPT
{% endblock %}
