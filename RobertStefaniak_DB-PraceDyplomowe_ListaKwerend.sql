USE [master]
GO

CREATE DATABASE [PraceDyplomowe]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'PraceDyplomowe', FILENAME = N'D:\MSSQL\DATA\PraceDyplomowe.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'PraceDyplomowe_log', FILENAME = N'D:\MSSQL\DATA\PraceDyplomowe_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO
ALTER DATABASE [PraceDyplomowe] SET COMPATIBILITY_LEVEL = 150
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [PraceDyplomowe].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [PraceDyplomowe] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [PraceDyplomowe] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [PraceDyplomowe] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [PraceDyplomowe] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [PraceDyplomowe] SET ARITHABORT OFF 
GO
ALTER DATABASE [PraceDyplomowe] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [PraceDyplomowe] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [PraceDyplomowe] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [PraceDyplomowe] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [PraceDyplomowe] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [PraceDyplomowe] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [PraceDyplomowe] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [PraceDyplomowe] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [PraceDyplomowe] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [PraceDyplomowe] SET  DISABLE_BROKER 
GO
ALTER DATABASE [PraceDyplomowe] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [PraceDyplomowe] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [PraceDyplomowe] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [PraceDyplomowe] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [PraceDyplomowe] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [PraceDyplomowe] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [PraceDyplomowe] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [PraceDyplomowe] SET RECOVERY FULL 
GO
ALTER DATABASE [PraceDyplomowe] SET  MULTI_USER 
GO
ALTER DATABASE [PraceDyplomowe] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [PraceDyplomowe] SET DB_CHAINING OFF 
GO
ALTER DATABASE [PraceDyplomowe] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [PraceDyplomowe] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [PraceDyplomowe] SET DELAYED_DURABILITY = DISABLED 
GO
EXEC sys.sp_db_vardecimal_storage_format N'ProjektBazyDanych', N'ON'
GO
ALTER DATABASE [PraceDyplomowe] SET QUERY_STORE = OFF
GO
USE [PraceDyplomowe]
GO

/***  Tworzenie funkcji ***/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[CzyJestPrzewodniczacym] (@idpraca int, @idprzewodniczacy int)
RETURNS int
AS 
BEGIN
  DECLARE @idpromotor int
  DECLARE @idrecenzent int
  DECLARE @wynik int

    SELECT @idpromotor = ID_Promotor
		FROM dbo.PracaDyplomowa
		WHERE ID_Praca = @idpraca

    SELECT @idrecenzent = ID_Recenzent
		FROM dbo.Recenzja
		WHERE ID_Praca = @idpraca

	SELECT @wynik = CASE 
						WHEN @idprzewodniczacy is null THEN 0
						WHEN @idpromotor = @idprzewodniczacy or @idrecenzent = @idprzewodniczacy THEN 1 ELSE 0 END
  RETURN @wynik
END;
GO

/***  Tworzenie funkcji ***/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[CzyJestRecenzentem] (@idpraca int, @idrecenzent int)
RETURNS int
AS 
BEGIN
  DECLARE @idpromotor int
  DECLARE @idprzewodniczacy int
  DECLARE @wynik int

    SELECT @idpromotor = ID_Promotor
		FROM dbo.PracaDyplomowa
		WHERE ID_Praca = @idpraca

    SELECT @idprzewodniczacy = ID_Przewodniczacy
		FROM dbo.Obrona
		WHERE ID_Praca = @idpraca

	SELECT @wynik = CASE 
						WHEN @idpromotor = @idrecenzent or @idprzewodniczacy = @idrecenzent THEN 1 ELSE 0 END
  RETURN @wynik
END;
GO

/***  Tworzenie funkcji ***/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[IluStudentowDoPracy] (@studentid nvarchar(10), @pracaid int)
RETURNS int
AS 
BEGIN
  DECLARE @wynik int
  DECLARE @liczba int
    SELECT @liczba = COUNT(ID_Autor)
		FROM dbo.Obrona
		WHERE ID_Praca = @pracaid
		GROUP BY ID_Praca	
	SELECT @wynik = CASE WHEN @liczba <= 3 THEN 0 ELSE 1 END
  RETURN @wynik
END;
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MiejsceObrony](
	[ID_MiejsceObrony] [int] IDENTITY(1,1) NOT NULL,
	[Budynek] [varchar](max) NOT NULL,
	[Adres] [varchar](50) NOT NULL,
	[Sala] [smallint] NOT NULL,
 CONSTRAINT [PK_MiejsceObrony] PRIMARY KEY CLUSTERED 
(
	[ID_MiejsceObrony] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Obrona](
	[ID_Obrona] [int] IDENTITY(1,1) NOT NULL,
	[ID_Autor] [bigint] NOT NULL,
	[ID_Przewodniczacy] [int] NOT NULL,
	[ID_Praca] [int] NOT NULL,
	[OcenaKoncowa] [smallint] NULL,
	[DataObrony] [datetime] NULL,
	[ID_MiejsceObrony] [int] NULL,
 CONSTRAINT [PK_Obrona] PRIMARY KEY CLUSTERED 
(
	[ID_Obrona] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PracaDyplomowa](
	[ID_Praca] [int] IDENTITY(1,1) NOT NULL,
	[TematPracy] [varchar](max) NOT NULL,
	[ID_TypStudiow] [int] NOT NULL,
	[ID_Promotor] [int] NULL,
	[DataZlozenia] [datetime] NULL,
 CONSTRAINT [PK_PracaDyplomowa] PRIMARY KEY CLUSTERED 
(
	[ID_Praca] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Pracownik](
	[ID_Pracownik] [int] IDENTITY(1,1) NOT NULL,
	[ID_StopienNaukowy] [int] NULL,
	[Imie] [varchar](100) NOT NULL,
	[Nazwisko] [varchar](100) NOT NULL,
	[Telefon] [int] NULL,
	[Email] [varchar](100) NULL,
 CONSTRAINT [PK_Uzytkownik] PRIMARY KEY CLUSTERED 
(
	[ID_Pracownik] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Recenzja](
	[ID_Recenzja] [int] IDENTITY(1,1) NOT NULL,
	[ID_Praca] [int] NOT NULL,
	[ID_Recenzent] [int] NOT NULL,
	[Ocena] [smallint] NULL,
	[DataOceny] [datetime] NULL,
	[Komentarz] [varchar](max) NULL,
 CONSTRAINT [PK_Recenzja] PRIMARY KEY CLUSTERED 
(
	[ID_Recenzja] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SlowaKluczowe](
	[ID_SlowoKluczowe] [int] IDENTITY(1,1) NOT NULL,
	[ID_Slowo] [int] NOT NULL,
	[ID_Praca] [int] NOT NULL,
 CONSTRAINT [PK_SlowaKluczowe] PRIMARY KEY CLUSTERED 
(
	[ID_SlowoKluczowe] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Slownik](
	[ID_Slowo] [int] IDENTITY(1,1) NOT NULL,
	[NazwaSlowaKluczowego] [varchar](50) NOT NULL,
 CONSTRAINT [PK_Slownik] PRIMARY KEY CLUSTERED 
(
	[ID_Slowo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[StopienNaukowy](
	[ID_StopienNaukowy] [int] IDENTITY(1,1) NOT NULL,
	[NazwaStopnia] [varchar](20) NOT NULL,
 CONSTRAINT [PK_StopienNaukowy] PRIMARY KEY CLUSTERED 
(
	[ID_StopienNaukowy] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Student](
	[ID_Student] [bigint] IDENTITY(1,1) NOT NULL,
	[ID_Studia] [int] NOT NULL,
	[Imie] [varchar](100) NOT NULL,
	[Nazwisko] [varchar](100) NOT NULL,
	[Telefon] [int] NULL,
	[Email] [varchar](50) NULL,
 CONSTRAINT [PK_Student] PRIMARY KEY CLUSTERED 
(
	[ID_Student] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Studia](
	[ID_Studia] [int] IDENTITY(1,1) NOT NULL,
	[Wydzial] [varchar](max) NOT NULL,
	[Kierunek] [varchar](max) NOT NULL,
 CONSTRAINT [PK_Studia] PRIMARY KEY CLUSTERED 
(
	[ID_Studia] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TypStudiow](
	[ID_Typ] [int] IDENTITY(1,1) NOT NULL,
	[TypStudiow] [varchar](50) NOT NULL,
 CONSTRAINT [PK_TypStudiow] PRIMARY KEY CLUSTERED 
(
	[ID_Typ] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Obrona]  WITH CHECK ADD  CONSTRAINT [FK_Obrona_MiejsceObrony] FOREIGN KEY([ID_MiejsceObrony])
REFERENCES [dbo].[MiejsceObrony] ([ID_MiejsceObrony])
GO
ALTER TABLE [dbo].[Obrona] CHECK CONSTRAINT [FK_Obrona_MiejsceObrony]
GO
ALTER TABLE [dbo].[Obrona]  WITH CHECK ADD  CONSTRAINT [FK_Obrona_PracaDyplomowa] FOREIGN KEY([ID_Praca])
REFERENCES [dbo].[PracaDyplomowa] ([ID_Praca])
GO
ALTER TABLE [dbo].[Obrona] CHECK CONSTRAINT [FK_Obrona_PracaDyplomowa]
GO
ALTER TABLE [dbo].[Obrona]  WITH CHECK ADD  CONSTRAINT [FK_Obrona_Pracownik] FOREIGN KEY([ID_Przewodniczacy])
REFERENCES [dbo].[Pracownik] ([ID_Pracownik])
GO
ALTER TABLE [dbo].[Obrona] CHECK CONSTRAINT [FK_Obrona_Pracownik]
GO
ALTER TABLE [dbo].[Obrona]  WITH CHECK ADD  CONSTRAINT [FK_Obrona_Student] FOREIGN KEY([ID_Autor])
REFERENCES [dbo].[Student] ([ID_Student])
GO
ALTER TABLE [dbo].[Obrona] CHECK CONSTRAINT [FK_Obrona_Student]
GO
ALTER TABLE [dbo].[PracaDyplomowa]  WITH CHECK ADD  CONSTRAINT [FK_PracaDyplomowa_Pracownik] FOREIGN KEY([ID_Promotor])
REFERENCES [dbo].[Pracownik] ([ID_Pracownik])
GO
ALTER TABLE [dbo].[PracaDyplomowa] CHECK CONSTRAINT [FK_PracaDyplomowa_Pracownik]
GO
ALTER TABLE [dbo].[PracaDyplomowa]  WITH CHECK ADD  CONSTRAINT [FK_PracaDyplomowa_TypStudiow] FOREIGN KEY([ID_TypStudiow])
REFERENCES [dbo].[TypStudiow] ([ID_Typ])
GO
ALTER TABLE [dbo].[PracaDyplomowa] CHECK CONSTRAINT [FK_PracaDyplomowa_TypStudiow]
GO
ALTER TABLE [dbo].[Pracownik]  WITH CHECK ADD  CONSTRAINT [FK_Pracownik_StopienNaukowy] FOREIGN KEY([ID_StopienNaukowy])
REFERENCES [dbo].[StopienNaukowy] ([ID_StopienNaukowy])
GO
ALTER TABLE [dbo].[Pracownik] CHECK CONSTRAINT [FK_Pracownik_StopienNaukowy]
GO
ALTER TABLE [dbo].[Recenzja]  WITH CHECK ADD  CONSTRAINT [FK_Recenzja_PracaDyplomowa] FOREIGN KEY([ID_Praca])
REFERENCES [dbo].[PracaDyplomowa] ([ID_Praca])
GO
ALTER TABLE [dbo].[Recenzja] CHECK CONSTRAINT [FK_Recenzja_PracaDyplomowa]
GO
ALTER TABLE [dbo].[Recenzja]  WITH CHECK ADD  CONSTRAINT [FK_Recenzja_Pracownik] FOREIGN KEY([ID_Recenzent])
REFERENCES [dbo].[Pracownik] ([ID_Pracownik])
GO
ALTER TABLE [dbo].[Recenzja] CHECK CONSTRAINT [FK_Recenzja_Pracownik]
GO
ALTER TABLE [dbo].[SlowaKluczowe]  WITH CHECK ADD  CONSTRAINT [FK_SlowaKluczowe_PracaDyplomowa] FOREIGN KEY([ID_Praca])
REFERENCES [dbo].[PracaDyplomowa] ([ID_Praca])
GO
ALTER TABLE [dbo].[SlowaKluczowe] CHECK CONSTRAINT [FK_SlowaKluczowe_PracaDyplomowa]
GO
ALTER TABLE [dbo].[SlowaKluczowe]  WITH CHECK ADD  CONSTRAINT [FK_SlowaKluczowe_Slownik] FOREIGN KEY([ID_Slowo])
REFERENCES [dbo].[Slownik] ([ID_Slowo])
GO
ALTER TABLE [dbo].[SlowaKluczowe] CHECK CONSTRAINT [FK_SlowaKluczowe_Slownik]
GO
ALTER TABLE [dbo].[Student]  WITH CHECK ADD  CONSTRAINT [FK_Student_Studia] FOREIGN KEY([ID_Studia])
REFERENCES [dbo].[Studia] ([ID_Studia])
GO
ALTER TABLE [dbo].[Student] CHECK CONSTRAINT [FK_Student_Studia]
GO

ALTER DATABASE [PraceDyplomowe] SET  READ_WRITE 
GO

