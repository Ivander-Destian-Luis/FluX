# flux

## Guide Penggunaan Services
### Authentication Service
Proses untuk melakukan login, register, dan logout dilakukan di Authentication Service. Semua method berjenis static sehingga tidak perlu dilakukan pembuatan objek.
1. login(String email, String password)<br />
   Login membutuhkan 2 parameter, yaitu email dan password. Terdapat nilai kembalian berupa message dan status code (untuk saat ini belum diimplementasi).
2. register(String email, String password)<br />
   Register membutuhkan 2 parameter, yaitu email dan password. Terdapat nilai kembalian berupa message dan status code (untuk saat ini belum diimplementasi).
3. logout()<br />
   Untuk melakukan logout akun, cukup panggil static method saja. Tidak mengembalikan nilai.

### Post Service
Proses untuk melakukan post, addPostingImage, like, dislike, comment, getPostingList, getCommentsLength. Semua method berjenis static sehingga tidak perlu dilakukan pembuatan objek.
1. post(Posting post, String uid)<br />
   Detail parameter:
   - <b>uid</b>: berupa user_id dari pembuat posting.
   - <b>post</b>: berupa model posting yang berisi:
       - <b>posterUid</b>: berupa user_id dari pembuat posting.
       - <b>postId</b>: berupa id untuk post (dapat dikosongkan untuk melakukan proses post)
       - <b>postingDescription</b>: berupa deskripsi untuk postingan.
       - <b>location</b>: nama kota atau wilayah postingan.
       - <b>likes</b>: berupa kumpulan uid yang menyukai postingan (dapat berupa list kosong untuk melakukan proses post)
       - <b>comments</b>: berupa map dari user_id dan list komentar dari user tersebut. (dapat berupa map kosong untuk melakukan proses post)
       - <b>postedTime</b>: berupa waktu saat melakukan posting.
       - <b>postingImageUrl</b>: berupa link dari gambar untuk mengambil gambar dari storage firebase. (dapat dikosongkan jika poster tidak ingin mengupload image)
2. addPostingImage(File? selectedImage)<br />
   Detail parameter:
   - <b>selectedImage</b>: berupa file setelah poster mengupload gambar yang ingin dia upload untuk posting. (posting tidak diwajibkan untuk menyertakan image)
   Kembalian:
   - Berupa String link dari gambar yang telah diupload.
3. like(String uid, Posting posting)<br />
   Detail parameter:
   - <b>uid</b>: berupa user_id yang ingin menyukai postingan yang dipost.
   - <b>posting</b>: berupa model posting dari posting yang sudah dipost.
4. dislike(String uid, Posting posting)<br />
   Detail parameter:
   - <b>uid</b>: berupa user_id yang ingin membatalkan untuk menyukai postingan yang dipost.
   - <b>posting</b>: berupa model posting dari posting yang sudah dipost.
5. comment(String uid, String comment, Posting posting)<br />
   Detail parameter:
   - <b>uid</b>: berupa user_id yang ingin mengomentari posting.
   - <b>comment</b>: berupa teks yang berisi komentar dari user.
   - <b>posting</b>: berupa posting yang ingin dikomentari.
6. getPostingList()<br />
   Proses untuk mengambil semua postingan yang telah dipost oleh semua user. Method ini akan mengembalikan Stream<List<Posting>> yang digunakan untuk widget StreamBuilder supaya bersifat realtime.
7. getCommentsLength(Posting post)<br />
   Untuk mendapatkan jumlah komentar dari postingan.

### Account Service
Proses untuk melakukan menambahkan akun baru, menambahkan photo profile, mengambil akun berdasarkan uid, mengambil uid berdasarkan username, mengambil kumpulan akun yang memiliki username yang sama, mengedit akun, follow akun, dan unfollow akun.
1. addUser(String username, String phoneNumber, String bio, String? profileImageUrl)<br />
   Proses untuk menambahkan akun baru ke firestore database.<br /?
   Detail parameter:
   - <b>username</b>: berupa string dari username yang telah diinput user.
   - <b>phoneNumber</b>: berupa string dari nomor telepon yang telah diinput user.
   - <b>bio</b>: berupa string dari bio yang telah diinput user.
   - <b>profileImageUrl</b>: didapat setelah user mengupload foto profilnya. (Dapat dikosongkan jika user tidak ingin menampilkan foto profil)
2. addPhotoProfile(File? selectedImage)<br />
   Proses upload foto profil ke storage firebase.<br />
   Detail parameter:
   - <b>selectedImage</b>: berupa file setelah user mengupload gambar yang ingin dia upload untuk foto profilnya. (user tidak diwajibkan untuk menyertakan image)
   Kembalian:
   - Berupa String link dari gambar yang telah diupload.
3. getAccountByUid(String uid)<br />
   Proses untuk mengambil model account berdasarkan user_id yang dimasukkan.<br />
   Detail parameter:
   - <b>uid</b>: berupa user_id yang digunakan untuk pengambilan account
4. getUidByUsername(String username)<br />
   Proses untuk mengambil uid berdasarkan username yang dimasukkan.<br />
   Detail parameter:
   - <b>username</b>: berupa username yang digunakan untuk pengambilan uid.
5. getAccountsByUsername(String username)<br />
   Proses untuk mengambil kumpulan accounts yang menggunakan username yang sama. (Digunakan untuk proses pencarian account)<br />
   Detail parameter:
   - <b>username</b>: berupa username yang digunakan untuk pencarian akun.
6. edit(String uid, String? username, String? phoneNumber, String? bio, List<dynamic>? followings, List<dynamic>? followers, String? profilePictureUrl, int? posts)<br />
   Proses untuk mengedit data user.<br />
   Detail parameter:
   - <b>uid</b>: berupa user_id yang ingin diubah datanya.
   - <b>username</b>: berupa username baru setelah diubah (dapat dikosongkan jika tidak ingin mengubah / NULL)
   - <b>phoneNumber</b>: berupa nomor HP baru setelah diubah (dapat dikosongkan jika tidak ingin mengubah / NULL)
   - <b>bio</b>: berupa bio baru setelah diubah (dapat dikosongkan jika tidak ingin mengubah / NULL)
   - <b>followings</b>: berupa followings baru untuk ditambah atau dikurang (digunakan dalam proses follow)
   - <b>followers</b>: berupa followers baru untuk ditambah atau dikurang (digunakan dalam proses follow)
   - <b>profilePictureUrl</b>: berupa link foto profil baru setelah diubah (dapat dikosongkan jika tidak ingin mengubah / NULL)
   - <b>posts</b>: berupa jumlah yang telah akun ini post. (digunakan untuk proses post)
7. follow(String uid, String targetUid)<br />
   Proses untuk mengikuti akun orang lain.<br />
   Detail parameter:
   - <b>uid</b>: berupa user_id dari orang yang ingin meng-follow.
   - <b>targetUid</b>: berupa user_id dari orang yang ingin difollow.
8. unfollow(String uid, String targetUid)<br />
   Proses untuk membatalkan mengikuti akun orang lain.<br />
   - <b>uid</b>: berupa user_id dari orang yang ingin meng-unfollow.
   - <b>targetUid</b>: berupa user_id dari orang yang ingin di-unfollow.
