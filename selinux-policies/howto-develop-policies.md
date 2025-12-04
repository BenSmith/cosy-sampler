You can use SELinux permissive mode for specific domains. This will log all the AVC denials but still allow the operations to proceed, so your applications work normally while you collect the needed permissions.

#### This workflow lets you:
1. Run your application normally (no denials blocking functionality)
2. Collect all the AVC denials in the audit log
3. Build up a comprehensive list of needed permissions
4. Update your policy files
5. Switch back to enforcing mode once the policy is complete

---
### Make your container types permissive
```bash
semanage permissive -a cosy_default_systemd_t
semanage permissive -a cosy_strict_systemd_t
```

### View Permissive Domains
```bash
semanage permissive -l
```

### Rotate audit log to start fresh
```bash
service auditd rotate
```
Note: Unlike most services, you should not use systemctl restart auditd - use the rotation command instead. Auditd is special because it's a security service that needs to maintain continuity.

### Add log marker
```bash
auditctl -m "=== TEST START ==="
```

### Run your contained app(s)
```bash
cosy run browse firefox
```

### View recent AVCs
```bash
ausearch -m avc -ts recent
```

### Generate policy rules from AVCs
```bash
ausearch -m avc -ts recent | audit2allow -R
```

### Or for a specific type
```bash
ausearch -m avc -c cosy_default_systemd_t -ts recent | audit2allow -R
```

### Remove Permissive Mode

```bash
semanage permissive -d cosy_default_systemd_t
semanage permissive -d cosy_strict_systemd_t
```


