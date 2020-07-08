# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import data as d with context %}
{%- set formula = d.formula %}

    {%- if 'environ' in d.node and d.node.environ %}
        {%- set sls_archive_install = tplroot ~ '.node.archive.install' %}
        {%- set sls_package_install = tplroot ~ '.node.package.install' %}
        {%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}

include:
  - {{ sls_archive_install if d.node.pkg.use_upstream_archive else sls_package_install }}

{{ formula }}-node-config-file-managed-environ_file:
  file.managed:
    - name: {{ d.node.environ_file }}
    - source: {{ files_switch(['environ.sh.jinja'],
                              lookup='k8s-node-config-file-managed-environ_file'
                 )
              }}
    - mode: '0640'
    - user: {{ d.identity.rootuser }}
    - group: {{ d.identity.rootgroup }}
    - makedirs: True
    - template: jinja
    - context:
        environ: {{ d.node.environ|json }}
    - require:
      - sls: {{ sls_archive_install if d.node.pkg.use_upstream_archive else sls_package_install }}

    {%- endif %}
