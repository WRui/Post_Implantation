import sys

def parse_opt(l_options):
    gene = "__"
    for opt in l_options:
        f_opt = opt.split(":")
        if f_opt[0] == "XF" and f_opt[1] == "Z":
            gene = f_opt[2]

    return gene


M_gen_UMI = {}
with open(sys.argv[1],"r") as f_infile:
    for line in f_infile:
        line = line.strip()
        f = line.split()
        UMI = f[0][0:8]
        l_options = f[11:]
        gene = parse_opt(l_options)
        if gene[0:2] == "__":
            continue

        if gene not in M_gen_UMI:
            M_gen_UMI[gene] = {}

        if UMI  not in M_gen_UMI[gene]:
            M_gen_UMI[gene][UMI] = 0

        M_gen_UMI[gene][UMI] += 1

keys=M_gen_UMI.keys()

sum=0

with open(sys.argv[2],"w") as out:
    for gene in sorted(keys):
        out.write("%s\t%d\n" % (gene,len(M_gen_UMI[gene])))
    #sum+=len(M_gen_UMI[gene])
