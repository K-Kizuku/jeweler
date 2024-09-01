package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/exec"
	"path/filepath"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/s3"
)

func main() {
	projectDir := "./jeweler"
	ctx := context.Background()
	fmt.Println("hey")
	cfg, err := config.LoadDefaultConfig(ctx)
	if err != nil {
		fmt.Println("Failed to Load Credentials")
	}
	client := s3.NewFromConfig(cfg)

	mux := http.NewServeMux()
	mux.HandleFunc("/{id}", func(w http.ResponseWriter, r *http.Request) {
		id := r.PathValue("id")
		if err := buildReactProject(projectDir); err != nil {
			fmt.Printf("Failed to build React project: %v\n", err)
		}

		buildDir := filepath.Join(projectDir, "dist")

		if err := uploadDirToS3(ctx, client, buildDir, id, "jeweler-storage"); err != nil {
			fmt.Printf("Failed to upload to S3: %v\n", err)
		}
		fmt.Println("Files uploaded to S3 successfully!")
		fmt.Fprint(w, "OK")
	})

	log.Fatal(http.ListenAndServe(":8080", mux))

}

func uploadDirToS3(ctx context.Context, client *s3.Client, dir, name, bucket string) error {
	err := filepath.Walk(dir, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}
		if !info.IsDir() {
			file, err := os.Open(path)
			if err != nil {
				return err
			}
			defer file.Close()

			_, err = client.PutObject(ctx, &s3.PutObjectInput{
				Bucket: aws.String(bucket),
				Key:    aws.String(name), // S3内のパス
				Body:   file,
			})
			if err != nil {
				return err
			}
		}
		return nil
	})

	return err
}

func buildReactProject(dir string) error {
	cmd := exec.Command("pnpm", "run", "build")
	cmd.Dir = dir

	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	return cmd.Run()
}
