{% extends 'iptables.filter.part' %}
{% block svc %}
# postgresql
-A INPUT -s {{ lookup('dig', 'amsapi.ooni.nu/A') }}/32 -p tcp -m tcp --dport 5432 -j ACCEPT
-A INPUT -s {{ lookup('dig', 'amsapi02.ooni.nu/A') }}/32 -p tcp -m tcp --dport 5432 -j ACCEPT
-A INPUT -s {{ lookup('dig', 'miaapi.ooni.nu/A') }}/32 -p tcp -m tcp --dport 5432 -j ACCEPT
{% endblock %}
