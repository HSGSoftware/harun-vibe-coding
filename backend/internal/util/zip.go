package util

import (
	"archive/zip"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"strings"
)

// ZipDir compresses srcDir into dstZip. Hidden paths starting with "." are included.
// Skip patterns is a list of rel path prefixes to exclude (e.g. "node_modules", ".git").
func ZipDir(srcDir, dstZip string, skip []string) error {
	absSrc, err := filepath.Abs(srcDir)
	if err != nil {
		return fmt.Errorf("abs src: %w", err)
	}
	f, err := os.Create(dstZip)
	if err != nil {
		return fmt.Errorf("create zip: %w", err)
	}
	defer f.Close()
	w := zip.NewWriter(f)
	defer w.Close()

	return filepath.Walk(absSrc, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}
		rel, err := filepath.Rel(absSrc, path)
		if err != nil {
			return err
		}
		if rel == "." {
			return nil
		}
		for _, s := range skip {
			if rel == s || strings.HasPrefix(rel, s+string(filepath.Separator)) {
				if info.IsDir() {
					return filepath.SkipDir
				}
				return nil
			}
		}
		if info.IsDir() {
			_, err := w.Create(rel + "/")
			return err
		}
		src, err := os.Open(path)
		if err != nil {
			return fmt.Errorf("open %s: %w", path, err)
		}
		defer src.Close()
		header, err := zip.FileInfoHeader(info)
		if err != nil {
			return err
		}
		header.Name = rel
		header.Method = zip.Deflate
		writer, err := w.CreateHeader(header)
		if err != nil {
			return err
		}
		if _, err := io.Copy(writer, src); err != nil {
			return fmt.Errorf("copy %s: %w", path, err)
		}
		return nil
	})
}

// UnzipTo extracts srcZip into dstDir. Entries that try to escape dstDir are rejected.
func UnzipTo(srcZip, dstDir string) error {
	r, err := zip.OpenReader(srcZip)
	if err != nil {
		return fmt.Errorf("open zip: %w", err)
	}
	defer r.Close()
	absDst, err := filepath.Abs(dstDir)
	if err != nil {
		return fmt.Errorf("abs dst: %w", err)
	}
	if err := os.MkdirAll(absDst, 0o755); err != nil {
		return err
	}
	for _, f := range r.File {
		target, err := SafeJoin(absDst, f.Name)
		if err != nil {
			return fmt.Errorf("unsafe entry %q: %w", f.Name, err)
		}
		if f.FileInfo().IsDir() {
			if err := os.MkdirAll(target, f.Mode()); err != nil {
				return err
			}
			continue
		}
		if err := os.MkdirAll(filepath.Dir(target), 0o755); err != nil {
			return err
		}
		out, err := os.OpenFile(target, os.O_WRONLY|os.O_CREATE|os.O_TRUNC, f.Mode())
		if err != nil {
			return err
		}
		in, err := f.Open()
		if err != nil {
			out.Close()
			return err
		}
		if _, err := io.Copy(out, in); err != nil {
			out.Close()
			in.Close()
			return err
		}
		out.Close()
		in.Close()
	}
	return nil
}
