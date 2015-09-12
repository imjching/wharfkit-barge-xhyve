init: vm uuid2mac

vm:
	@$(MAKE) -sC vm

clean destroy: exports-clean uuid2mac-clean
	$(MAKE) -C vm clean

.PHONY: init vm clean destroy

#
# Commands
#

IP_ADDR  := `bin/mac2ip.sh $$(cat vm/.mac_address)`
USERNAME := $(shell make -sC vm username)
PASSWORD := $(shell make -sC vm password)
SSH_ARGS := $(shell make -sC vm ssh_args)

run up: | init
	@sudo echo "Booting up..." # to input password at the current window in advance 
	@bin/xhyveexec.sh

mac: | status
	@cat vm/.mac_address

ip: | status
	@echo $(IP_ADDR)

ssh: | status
	@expect -c ' \
		spawn -noecho ssh $(USERNAME)@'$(IP_ADDR)' $(SSH_ARGS) $(filter-out $@,$(MAKECMDGOALS)); \
		expect "(yes/no)?" { send "yes\r"; exp_continue; } "password:" { send "$(PASSWORD)\r"; }; \
		interact; \
	'

halt: | status
	@expect -c ' \
		spawn -noecho ssh $(USERNAME)@'$(IP_ADDR)' $(SSH_ARGS) sudo halt; \
		expect "(yes/no)?" { send "yes\r"; exp_continue; } "password:" { send "$(PASSWORD)\r"; }; \
		interact; \
	'
	@echo "Shutting down..."

reboot reload: | status
	@expect -c ' \
		spawn -noecho ssh $(USERNAME)@'$(IP_ADDR)' $(SSH_ARGS) sudo reboot; \
		expect "(yes/no)?" { send "yes\r"; exp_continue; } "password:" { send "$(PASSWORD)\r"; }; \
		interact; \
	'
	@echo "Rebooting..."

env: | status
	@echo "export DOCKER_HOST=tcp://$(IP_ADDR):2375;"
	@echo "unset DOCKER_CERT_PATH;"
	@echo "unset DOCKER_TLS_VERIFY;"

status:
	@if [ ! -f vm/.mac_address ]; then \
		echo "docker-root-xhyve: stopped"; \
		exit 1; \
	else \
		if ping -c 1 -t 1 $(IP_ADDR) >/dev/null 2>&1; then \
			echo "docker-root-xhyve: running on $(IP_ADDR)"; \
		else \
			echo "docker-root-xhyve: starting"; \
			exit 1; \
		fi; \
	fi >&2;

.PHONY: run up mac ip ssh halt reboot reload env status

.DEFAULT:
	@:

#
# Helpers
#

EXPORTS = $(shell bin/vmnet_export.sh)

exports:
	@if [ -n "$(EXPORTS)" ]; then \
		sudo touch /etc/exports; \
		if ! grep -qs '^$(EXPORTS)$$' /etc/exports; then \
			echo '$(EXPORTS)' | sudo tee -a /etc/exports; \
		fi; \
		sudo nfsd restart; \
	else \
		echo "It seems your first run for xhyve with vmnet."; \
		echo "You can't use NFS shared folder at this time."; \
		echo "But it should be available at the next boot."; \
	fi;

exports-clean:
	@if [ -n "$(EXPORTS)" ]; then \
		sudo touch /etc/exports; \
		sudo sed -E -e '/^\$(EXPORTS)$$/d' -i.bak /etc/exports; \
		sudo nfsd restart; \
	fi;

.PHONY: exports exports-clean

uuid2mac: bin/uuid2mac

bin/uuid2mac:
	$(MAKE) -C uuid2mac
	@install -CSv uuid2mac/build/uuid2mac bin/

uuid2mac-clean:
	$(MAKE) -C uuid2mac clean
	$(RM) bin/uuid2mac

.PHONY: uuid2mac uuid2mac-clean
