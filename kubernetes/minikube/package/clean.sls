# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import data as d with context %}
{%- set formula = d.formula %}

    {%- if grains.kernel|lower in ('linux',) %}
        {%- if d.minikube.pkg.use_upstream_repo %}
            {%- set sls_repo_clean = tplroot ~ '.package.repo.clean' %}
include:
  - {{ sls_repo_clean }}
        {%- endif %}

{{ formula }}-minikube-package-clean-pkg:
  pkg.removed:
    - name: {{ d.minikube.pkg.name }}
    - reload_modules: true
        {%- if d.minikube.pkg.use_upstream_repo %}
    - require:
      - pkgrepo: {{ formula }}-package-repo-absent
        {%- endif %}

    {%- elif grains.os_family == 'MacOS' %}

{{ formula }}-minikube-package-clean-brew:
  cmd.run:
    - name: /usr/local/bin/brew uninstall {{ d.minikube.pkg.name }}
    - runas: {{ d.identity.rootuser }}
    - onlyif:
      - test -x /usr/local/bin/brew
      - /usr/local/bin/brew list | grep {{ d.minikube.pkg.name }}

    {%- elif grains.kernel|lower == 'linux' %}

{{ formula }}-minikube-package-clean-snap:
  cmd.run:
    - name: snap remove {{ d.minikube.pkg.name }}
    - onlyif: test -x /usr/bin/snap || test -x /usr/local/bin/snap

    {%- endif %}
