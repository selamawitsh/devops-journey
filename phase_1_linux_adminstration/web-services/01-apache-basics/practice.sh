#!/bin/bash
#
# 01-apache-basics/practice.sh
#
# A guided, step-by-step walkthrough of Apache fundamentals on Ubuntu.
# Run it section by section (it pauses between each) so you can actually
# read what happened before moving on — this is NOT meant to be run
# silently in the background.
#
# Usage: bash practice.sh

set -e

pause() {
    echo ""
    read -p "   >> Press ENTER to continue to the next step..." dummy
    echo ""
}

section() {
    echo ""
    echo "=================================================================="
    echo " $1"
    echo "=================================================================="
}

# ------------------------------------------------------------------
section "STEP 1: Install Apache"
# ------------------------------------------------------------------
echo "Command: sudo apt update && sudo apt install apache2 -y"
sudo apt update
sudo apt install apache2 -y

echo ""
echo "Now checking the service status..."
sudo systemctl status apache2 --no-pager || true
pause

# ------------------------------------------------------------------
section "STEP 2: Enable + start the service, confirm it's alive"
# ------------------------------------------------------------------
sudo systemctl enable apache2
sudo systemctl start apache2

echo "Hitting the server with curl to prove it responds:"
curl -s -o /dev/null -w "HTTP status: %{http_code}\n" http://localhost/
pause

# ------------------------------------------------------------------
section "STEP 3: DocumentRoot — prove the URL path = filesystem path"
# ------------------------------------------------------------------
echo "Creating /var/www/html/test/default.html ..."
sudo mkdir -p /var/www/html/test
echo "<h1>DocumentRoot in action</h1>" | sudo tee /var/www/html/test/default.html > /dev/null

echo ""
echo "Requesting http://localhost/test/default.html :"
curl -s http://localhost/test/default.html
echo ""
echo "Q: If this worked, what filesystem path did Apache actually read from?"
pause

# ------------------------------------------------------------------
section "STEP 4: Prove a 404 happens when the file doesn't exist"
# ------------------------------------------------------------------
echo "Requesting a file that doesn't exist..."
curl -s -o /dev/null -w "HTTP status: %{http_code}\n" http://localhost/test/does-not-exist.html

echo ""
echo "Check error.log for the corresponding entry:"
sudo tail -n 5 /var/log/apache2/error.log
pause

# ------------------------------------------------------------------
section "STEP 5: AllowOverride + htpasswd — build password protection"
# ------------------------------------------------------------------
echo "Installing apache2-utils for htpasswd..."
sudo apt install apache2-utils -y

echo ""
echo "Creating a private folder..."
sudo mkdir -p /var/www/html/private
echo "<h1>Secret content</h1>" | sudo tee /var/www/html/private/index.html > /dev/null

echo ""
echo "Creating a password file with user 'selam' (you'll be prompted for a password):"
sudo htpasswd -c /etc/apache2/.htpasswd selam

echo ""
echo "NOTE: at this point, protection WON'T work yet."
echo "We haven't set AllowOverride AuthConfig, and we haven't created .htaccess."
echo "That's the point of the next steps — watch it fail, then fix it."
pause

# ------------------------------------------------------------------
section "STEP 6: Create the .htaccess (still won't work yet — no override permission)"
# ------------------------------------------------------------------
sudo tee /var/www/html/private/.htaccess > /dev/null << 'EOF'
AuthType Basic
AuthName "Restricted Area"
AuthUserFile /etc/apache2/.htpasswd
Require valid-user
EOF

echo "Restarting apache2 and testing WITHOUT AllowOverride set..."
sudo systemctl restart apache2
curl -s -o /dev/null -w "HTTP status (expect 200, meaning NOT protected yet): %{http_code}\n" http://localhost/private/
pause

# ------------------------------------------------------------------
section "STEP 7: Grant AllowOverride AuthConfig, then re-test"
# ------------------------------------------------------------------
echo "Manual step required here — this script will NOT edit your Apache config"
echo "for you, because editing config files is a skill you need to practice"
echo "by hand, not something to copy-paste blindly."
echo ""
echo "Open: sudo nano /etc/apache2/apache2.conf"
echo "Add this block (anywhere at the top level, not nested inside another Directory):"
echo ""
cat << 'EOF'
    <Directory /var/www/html/private>
        AllowOverride AuthConfig
    </Directory>
EOF
echo ""
echo "Save, then restart apache2:  sudo systemctl restart apache2"
pause

echo "Now testing again — without credentials (expect 401):"
curl -s -o /dev/null -w "HTTP status: %{http_code}\n" http://localhost/private/

echo ""
echo "Now testing WITH credentials (expect 200):"
curl -s -u selam -o /dev/null -w "HTTP status: %{http_code}\n" http://localhost/private/
pause

# ------------------------------------------------------------------
section "STEP 8: Modules & handlers — install PHP, watch behavior change"
# ------------------------------------------------------------------
echo "Installing PHP + Apache module..."
sudo apt install php libapache2-mod-php -y

echo ""
echo "Listing available PHP module name (version may differ):"
ls /etc/apache2/mods-available/ | grep php

echo ""
echo "Creating a test PHP file BEFORE enabling the module..."
echo '<?php echo "PHP is alive"; ?>' | sudo tee /var/www/html/test.php > /dev/null

echo "Requesting it now (module likely already auto-enabled by the apt install,"
echo "but let's confirm what's active):"
apache2ctl -M | grep -i php || echo "(php module NOT currently active)"

curl -s http://localhost/test.php
echo ""
echo "^ If you see raw '<?php echo...' text, the module isn't enabled yet."
echo "  If you see 'PHP is alive', it's already active — try: sudo a2dismod php* && systemctl restart apache2"
echo "  then re-run curl to see the RAW source come back instead."
pause

# ------------------------------------------------------------------
section "STEP 9: Logs — watch access.log and error.log in real time"
# ------------------------------------------------------------------
echo "Open a SECOND terminal and run:"
echo "   sudo tail -f /var/log/apache2/access.log"
echo ""
echo "Then come back here and press ENTER — this script will fire a few"
echo "requests so you can watch them land live in that other terminal."
pause

curl -s -o /dev/null http://localhost/
curl -s -o /dev/null http://localhost/private/
curl -s -o /dev/null http://localhost/nonexistent-page
curl -s -o /dev/null http://localhost/test.php

echo ""
echo "Check your second terminal now — you should see 4 new lines land."
echo "Now check error.log for the 404 specifically:"
sudo tail -n 5 /var/log/apache2/error.log

echo ""
echo "=================================================================="
echo " Done. Open challenge.md for exercises to do WITHOUT this script."
echo "=================================================================="
