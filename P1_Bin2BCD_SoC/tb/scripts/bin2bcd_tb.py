# Author: Olaoluwa Raji

from pathlib import Path
import os
import shutil

TEST_DIR:    str   = "./test/"
FILENAME:    str   = "bin2bcd_tb_vectors.txt"
NUM_VECTORS: int   =  pow(2,16)  # Total number of testcases to generate

def main() -> None:
    if(os.path.exists(TEST_DIR)):
        shutil.rmtree(TEST_DIR)
    test_dir: Path = Path(TEST_DIR)
    test_dir.mkdir()    
    file_path: Path = test_dir / FILENAME

    testcases: list[int] = []
    for num in range(0,NUM_VECTORS):
        testcases.append(num)

    testcases.append(pow(2,32) - 1)

    # Write files
    with open(file_path, "w") as fa:
        for num in testcases:
            fa.write(f"{num} {num}\n")

    print(f"Wrote: {file_path}")

if __name__ == "__main__":
    main()