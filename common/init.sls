{% from tpldir ~ '/map.jinja' import common %}

python2:
  pkg.installed:
    - pkgs:
      - python
    {% if grains['os'] == 'MacOS' %}
    - refresh: True
    {% endif %}

{% if grains['os'] == 'Ubuntu' %}
python2-dev:
  pkg.installed:
    - pkgs:
      - python-dev
{% endif %}

pip:
  pkg.installed:
    - pkgs:
      {% if grains['os'] == 'Ubuntu' %}
      - python-pip
      {% elif grains['os'] == 'MacOS' %}
      - python # pip is included with python in homebrew
      {% endif %}
    - reload_modules: True

# virtualenv == 14.0.6 package creates virtualenv and virtualenv-3.5 executables
# note that the version of the second may change between virtualenv versions
virtualenv:
  pip.installed:
    - pkgs:
      - virtualenv == 14.0.6
    - require:
      - pkg: pip

servo:
  user.present:
    - fullname: Tom Servo
    - shell: /bin/bash
    - home: {{ common.servo_home }}

{% for ssh_user in common.ssh_users %}
sshkey-{{ ssh_user }}:
  ssh_auth.present:
    - user: root
    - source: salt://{{ tpldir }}/ssh/{{ ssh_user }}.pub
{% endfor %}

/etc/hosts:
  file.managed:
    - user: root
    - mode: 644
    {% if grains['os'] == 'MacOS' %}
    - group: wheel
    {% elif grains['os'] == 'Ubuntu' %}
    - group: root
    {% endif %}
    - source: salt://{{ tlpdir }}/files/hosts
