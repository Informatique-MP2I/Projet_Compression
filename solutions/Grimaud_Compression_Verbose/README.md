# Projet de Compression et Décompression

Ce projet implémente des algorithmes de compression et de décompression en OCaml. Il inclut plusieurs programmes principaux :

1. `compresshuffman` : compresse un fichier en utilisant l'algorithme de Huffman.
2. `decompresshuffman` : décompresse un fichier compressé avec l'algorithme de Huffman.
3. `compresslzw` : compresse un fichier en utilisant l'algorithme de Lempel-Ziv-Welch (LZW).
4. `decompresslzw` : décompresse un fichier compressé avec l'algorithme de Lempel-Ziv-Welch (LZW).
5. `dumpbits` : affiche le contenu binaire d'un fichier.

## Organisation des répertoires

Le projet est organisé comme suit :

- `bin` : contient les exécutables compilés.
- `build` : contient les fichiers intermédiaires générés lors de la compilation.
- `docs` : contient la documentation du projet.
- `misc` : contient des fichiers d'exemple pour tester les programmes.
- `src` : contient les fichiers source du projet.

## Utilisation des programmes

### Compilation

Pour compiler les programmes, utilisez le `Makefile` fourni. Les fichiers source sont situés dans le répertoire `src`, les fichiers intermédiaires dans `build`, et les exécutables seront placés dans `bin`.

```sh
make all
```

### compresshuffman

Ce programme compresse un fichier en utilisant l'algorithme de Huffman.

#### Usage :

```sh
./bin/compresshuffman [OPTIONS] <source> <destination>
```
#### Options :

* `-v`, `--verbose` : Affiche des informations détaillées pendant la compression.
* `-h`, `--help` : Affiche le message d'aide et quitte.

#### Exemples :

```sh
./bin/compresshuffman misc/test.txt misc/test.txt.huffman
./bin/compresshuffman -v misc/test.txt misc/test.txt.huffman
```

### decompresshuffman

Ce programme décompresse un fichier compressé avec l'algorithme de Huffman.

#### Usage :

```sh
./bin/decompresshuffman [OPTIONS] <source> <destination>
```

#### Options :

* `-v`, `--verbose` : Affiche des informations détaillées pendant la décompression.
* `-h`, `--help` : Affiche le message d'aide et quitte.

#### Exemples :

```sh
./bin/decompresshuffman misc/test.txt.huffman misc/test.txt
./bin/decompresshuffman -v misc/test.txt.huffman misc/test.txt
```

### compresslzw

Ce programme compresse un fichier en utilisant l'algorithme de Lempel-Ziv-Welch (LZW).

#### Usage : 

```sh
./bin/compresslzw [OPTIONS] <source> <destination>
```

#### Options :

* `-v`, `--verbose` : Affiche des informations détaillées pendant la compression.
* `-h`, `--help` : Affiche le message d'aide et quitte.

#### Exemples :

```sh
./bin/compresslzw misc/test.txt misc/test.txt.lzw
./bin/compresslzw -v misc/test.txt misc/test.txt.lzw
```

### decompresslzw

Ce programme décompresse un fichier compressé avec l'algorithme de Lempel-Ziv-Welch (LZW).

#### Usage : 

```sh
./bin/decompresslzw [OPTIONS] <source> <destination>
```

#### Options :

* `-v`, `--verbose` : Affiche des informations détaillées pendant la décompression.
* `-h`, `--help` : Affiche le message d'aide et quitte.

#### Exemples :

```sh
./bin/decompresslzw misc/test.txt.lzw misc/test.txt
./bin/decompresslzw -v misc/test.txt.lzw misc/test.txt
```

### dumpbits

Ce programme affiche le contenu binaire d'un fichier.

#### Usage :

```sh
./bin/dumpbits <filename>
```

#### Exemple :

```sh
./bin/dumpbits misc/test.txt.huffman
```

## Licence

Ce projet est sous licence LGPL (GNU Lesser General Public License). Pour plus
de détails, veuillez vous référer au fichier LICENSE fourni avec ce projet.

## Auteurs

- A. & G. Grimaud
- Date de création : 15 Juin 2024

