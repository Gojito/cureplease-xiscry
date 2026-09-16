namespace CurePlease
{
    using System.Windows.Forms;

    public partial class Form3 : Form
    {
        public Form3()
        {
            this.StartPosition = FormStartPosition.CenterScreen;

            this.InitializeComponent();

            this.label2.Text = Application.ProductVersion;
        }

        #region "== Form About"

        private void linkLabel1_LinkClicked(object sender, LinkLabelLinkClickedEventArgs e)
        {
            System.Diagnostics.Process.Start("https://github.com/atom0s/Cure-Please");
        }
    }

    #endregion "== Form About"
}
