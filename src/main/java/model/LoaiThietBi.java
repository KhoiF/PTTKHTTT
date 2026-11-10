package model;

import java.io.Serializable;
import java.util.ArrayList;

/** Loại thiết bị (3 module không dùng). */
public class LoaiThietBi implements Serializable {
    private static final long serialVersionUID = 1L;
    private int id;
    private String maLoai;
    private String tenLoai;
    private ArrayList<ThietBiPhucVu> dsThietBi = new ArrayList<>();

    public LoaiThietBi() {
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getMaLoai() {
        return maLoai;
    }

    public void setMaLoai(String maLoai) {
        this.maLoai = maLoai;
    }

    public String getTenLoai() {
        return tenLoai;
    }

    public void setTenLoai(String tenLoai) {
        this.tenLoai = tenLoai;
    }

    public ArrayList<ThietBiPhucVu> getDsThietBi() {
        return dsThietBi;
    }

    public void setDsThietBi(ArrayList<ThietBiPhucVu> dsThietBi) {
        this.dsThietBi = dsThietBi;
    }
}
