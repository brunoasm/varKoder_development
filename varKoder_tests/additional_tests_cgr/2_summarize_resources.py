import re
import csv

def parse_command(cmd):
    if "query" in cmd:
        return "query", None, None, None
        
    arch_match = re.search(r'-c\s+(\S+)', cmd)
    valid_match = re.search(r'-V\s+(\d+)', cmd)
    repr_match = re.search(r'datasets/([^/\s]+)/', cmd)
    
    arch = arch_match.group(1) if arch_match else None
    valid_samp = valid_match.group(1) if valid_match else None
    repr_name = repr_match.group(1) if repr_match else None
    
    phase = "pretrain" if "--random-weights" in cmd else "fine-tune"        
    return phase, arch, repr_name, valid_samp

def parse_time_stats(time_lines):
    stats = {}
    field_mapping = {
        'user time': ('user_time', float),
        'system time': ('system_time', float),
        'percent of cpu': ('cpu_percent', lambda x: float(x.rstrip('%'))),
        'shared text size': ('shared_text_kb', int),
        'unshared data size': ('unshared_data_kb', int),
        'stack size': ('stack_size_kb', int),
        'total size': ('total_size_kb', int),
        'maximum resident set size': ('max_resident_kb', int),
        'average resident set size': ('avg_resident_kb', int),
        'major': ('major_pagefaults', int),
        'minor': ('minor_pagefaults', int),
        'voluntary context switches': ('voluntary_switches', int),
        'involuntary context switches': ('involuntary_switches', int),
        'swaps': ('swaps', int),
        'file system inputs': ('fs_inputs', int),
        'file system outputs': ('fs_outputs', int),
        'socket messages sent': ('socket_msgs_sent', int),
        'socket messages received': ('socket_msgs_received', int),
        'signals delivered': ('signals', int),
        'page size': ('page_size', int),
        'exit status': ('exit_status', int)
    }

    for line in time_lines:
        if ':' not in line:
            continue
            
        key, value = line.split(':', 1)
        key = key.strip().lower()
        value = value.strip()

        if 'elapsed' in key:
            time_match = re.search(r'(\d+):(\d+.\d+)', value)
            if time_match:
                mins, secs = time_match.groups()
                stats['elapsed_time'] = float(mins) * 60 + float(secs)
            continue

        try:
            for pattern, (stat_key, converter) in field_mapping.items():
                if pattern in key:
                    stats[stat_key] = converter(value.split()[0])
                    break
        except:
            pass

    return stats

def parse_log(filename):
    records = []
    current_command = []
    current_time = []
    last_arch = None
    last_repr = None
    last_valid = None
    
    with open(filename) as f:
        for line in f:
            if line.startswith('\tCommand being timed:'):
                if current_command:
                    cmd = current_command[0].strip()
                    phase, arch, repr_name, valid_samp = parse_command(cmd)
                    stats = parse_time_stats(current_time)
                    
                    if phase == "query":
                        arch = last_arch
                        repr_name = last_repr
                        valid_samp = last_valid
                    else:
                        last_arch = arch
                        last_repr = repr_name
                        last_valid = valid_samp
                        
                    records.append([phase, arch, repr_name, valid_samp, stats])
                current_command = [line]
                current_time = []
            elif current_command and line.startswith('\t'):
                current_time.append(line)
                
    if current_command:
        cmd = current_command[0].strip()
        phase, arch, repr_name, valid_samp = parse_command(cmd)
        if phase == "query":
            arch = last_arch
            repr_name = last_repr
            valid_samp = last_valid
        stats = parse_time_stats(current_time)
        records.append([phase, arch, repr_name, valid_samp, stats])
                
    return records

def write_csv(records, outfile):
    # Get all stats keys from first record
    stat_keys = list(records[0][4].keys())
    headers = ['phase', 'architecture', 'representation', 'validation_sample'] + sorted(stat_keys)
    
    with open(outfile, 'w', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(headers)
        
        for record in records:
            phase, arch, repr_name, valid_samp, stats = record
            row = [phase, arch, repr_name, valid_samp]
            row.extend(stats.get(key, '') for key in headers[4:])
            writer.writerow(row)

# Usage            
records = parse_log('1_xval_all.out')
write_csv(records, 'computing_summary.csv')
