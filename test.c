#include <stdlib.h>
#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <dirent.h>
#include <sys/stat.h>
#include <libgen.h>
#include <time.h>
#include <signal.h>
#include <pthread.h>
#include <semaphore.h>

/* Test runner and report generator for Open Fortran Compiler*/

static char* OFC_GIT_COMMIT;
static char* OFC_GIT_URL;
static char* OFC_GIT_BRANCH;
static char* TESTS_GIT_COMMIT;
static char* TESTS_GIT_URL;


static void print_html_header(void)
{
	printf("<!doctype html>\n"
		"<html>\n"
		"<style TYPE=\"text/css\">\n"
		"<!--\n"
		"table\n"
		"{\n"
		"  width: 100%%;\n"
		"  border-collapse:separate;\n"
		"  border-spacing: 0;\n"
		"  border:solid #aaa 2px;\n"
		"  border-radius:6px;\n"
		"  -moz-border-radius:6px;\n"
		"}\n"
		"th\n"
		"{\n"
		"  height: 30px;\n"
		"}\n"
		"tr:nth-child(odd)\n"
		"{\n"
		"  background-color: #ccc;\n"
		"}\n"
		"tr:nth-child(even)\n"
		"{\n"
		"  background-color: #ddd;\n"
		"}\n"
		"td\n"
		"{\n"
		"  padding-left: 6px;\n"
		"}\n"
		"\n"
		"--!>\n"
		"</style>\n"
		"<head>\n"
		"<title>Open Fortran Compiler Test Report</title>\n"
		"<h1>Open Fortran Compiler Test Report</h1>\n"
		"</head>\n"
		"<body>\n");
}

static void print_html_report_info(void)
{
	printf("<p>This is the test report for Open Fortran Compiler (OFC).</p>");
	printf("<p>Branch: %s</p>", OFC_GIT_BRANCH);
	printf("<p>SHA1: <a href=\"%s/tree/%s\">%s</a></p>", OFC_GIT_URL, OFC_GIT_COMMIT, OFC_GIT_COMMIT);

	time_t t = time(NULL);
	struct tm* tm = gmtime(&t);
	if (!tm) abort();
	char* date = asctime(tm);
	if (!date) abort();

	printf("<p>Test run started: %s UTC</p>", date);
}

static void print_html_table_start(const char* header)
{
	printf("<h2>%s/</h2>\n", header);
	printf("<table>\n");
}

static void print_html_table_header(const char* name[])
{
	printf("<tr>");

	if (name)
	{
		unsigned i;
		for (i = 0; name[i]; i++)
			printf("<th>%s</th>", name[i]);
	}

	printf("</tr>\n");
}

static void print_html_table_row_start(void)
{
	printf("<tr>");
}

static void print_html_cell_bold(const char* text)
{
	printf("<td><b>%s</b></td>", text);
}

static void print_html_cell_centre(const char* text)
{
	printf("<td align=center>%s</td>", text);
}

static void print_html_cell_test_file(char* path)
{
	char* name = basename(path);
	printf ("<td><a href=\"%s/blob/%s/%s\">%s</a></td>",
		TESTS_GIT_URL, TESTS_GIT_COMMIT, path, name);
}

static void print_html_cell_semantic_file(char* path)
{
	char* name = basename(path);
	printf("<td><a href=\"%s.sema\">%s</a></td>", path, name);
}

static void print_html_cell_fail(
	int status, const char* link)
{
	printf("<td align=center><font color=\"#bf0000\">"
		"FAIL (%d)</font>%s</td>", status, (link ? link : ""));
}

static void print_html_cell_fail_non_crit(
	int status, const char* link)
{
	printf("<td align=center><font color=\"#ff5f00\">"
		"FAIL (%d)</font>%s</td>", status, (link ? link : ""));
}


static void print_html_cell_pass(const char* link)
{
	printf("<td align=center><font color=\"#00bf00\">"
		"PASS</font>%s</td>", (link ? link : ""));
}

static void print_html_cell_ignored(void)
{
	printf("<td align=center><font color=\"#3f3f3f\">-</font></td>");
}

static void print_html_cell_pass_fail(
	int status, const char* link)
{
	if (status == EXIT_SUCCESS)
		print_html_cell_pass(link);
	else
		print_html_cell_fail(status, link);
}

static void print_html_cell_pass_fail_non_crit(
	int status, const char* link)
{
	if (status == EXIT_SUCCESS)
		print_html_cell_pass(link);
	else
		print_html_cell_fail_non_crit(status, link);
}


static void print_html_table_row_end(void)
{
	printf("</tr>\n");
}

static void print_html_table_end(void)
{
	printf("</table>\n");
}

static void print_html_footer(void)
{
	printf("</body>\n</html>");
}



int system_sane(const char* cmd)
{
	int status = system(cmd);
	if (WIFEXITED(status))
		return WEXITSTATUS(status);
	return EXIT_FAILURE;
}



typedef struct
{
	char* path;
	bool  is_negative;

	bool test_behaviour;
	bool test_reingest;
	bool test_vg;
	bool test_vgo;

	volatile bool complete;

	int status_standard;
	int status_behaviour;
	int status_reingest;
	int status_vg;
	int status_vgo;
} job_t;

static unsigned job_count = 0;
static job_t**  job = NULL;

static void job_delete(job_t* j)
{
	if (!j) return;
	free(j->path);
	free(j);
}

static job_t* job_create(
	const char* path,
	bool is_negative,
	bool test_behaviour,
	bool test_reingest,
	bool test_vg)
{
	job_t* j = (job_t*)malloc(sizeof(job_t));
	if (!j) return NULL;

	j->path = strdup(path);
	if (!j->path)
	{
		free(j);
		return NULL;
	}

	j->is_negative = is_negative;

	j->test_behaviour = test_behaviour;
	j->test_reingest  = test_reingest;
	j->test_vg        = false;
	j->test_vgo       = test_vg;

	j->complete = false;

	j->status_standard  = false;
	j->status_behaviour = false;
	j->status_reingest  = false;
	j->status_vg        = false;
	j->status_vgo       = false;

	job_t** njob = (job_t**)realloc(job,
		(sizeof(job_t*) * (job_count + 1)));
	if (!njob)
	{
		job_delete(j);
		return NULL;
	}
	job = njob;
	job[job_count++] = j;

	return j;
}

struct job_exec_params
{
	char*  ofc;
	job_t* job;
};

sem_t job_exec_sem;
sem_t job_print_sem;

static void* job_exec(
	struct job_exec_params* params)
{
	if (!params || !params->job)
		return NULL;

	job_t* job = params->job;
	char*  ofc = params->ofc;

	if (job->complete)
		return NULL;

	size_t path_len = strlen(job->path);
	size_t ofc_len = strlen(ofc);
	char cmd[path_len + ofc_len + 256];

	sprintf(cmd, "FRONTEND=%s make out/%s.sema > /dev/null 2>&1", ofc, job->path);
	job->status_standard = system_sane(cmd);

	if (job->status_standard != EXIT_SUCCESS)
	{
		job->test_behaviour = false;
		job->test_reingest  = false;
		job->test_vgo       = false;
	}

	if (job->test_behaviour)
	{
		sprintf(cmd, "FRONTEND=%s make out/%s.expected > /dev/null 2>&1", ofc, job->path);
		job->status_behaviour = system_sane(cmd);
		if (job->status_behaviour == EXIT_SUCCESS)
		{
			sprintf(cmd, "./behaviour.sh %s out/%s.sema out/%s.expected out/%s.behaviour > /dev/null 2>&1",
				job->path, job->path, job->path, job->path);
			job->status_behaviour = system_sane(cmd);
		}
	}

	if (job->test_reingest)
	{
		sprintf(cmd, "FRONTEND=%s make out/%s.resema > /dev/null 2>&1", ofc, job->path);
		job->status_reingest = system_sane(cmd);
	}

	if (job->test_vgo)
	{
		sprintf(cmd, "FRONTEND=%s make out/%s.vgo > /dev/null 2>&1", ofc, job->path);
		job->status_vgo = system_sane(cmd);
		job->test_vg = (job->status_vgo != EXIT_SUCCESS);
	}

	if (job->test_vg)
	{
		sprintf(cmd, "FRONTEND=%s make out/%s.vg > /dev/null 2>&1", ofc, job->path);
		job->status_vg = system_sane(cmd);
	}

	job->complete = true;

	sem_post(&job_exec_sem);
	sem_post(&job_print_sem);
	return NULL;
}

static void job_print(
	const job_t* job,
	unsigned* pass,
	unsigned* pass_behaviour,
	unsigned* pass_reingest,
	unsigned* pass_vgo,
	unsigned* fail_vgo,
	unsigned* pass_vg)
{
	print_html_table_row_start();
	print_html_cell_test_file(job->path);

	char msg[strlen(job->path) + 256];

	while (!job->complete)
		sem_wait(&job_print_sem);

	if (job->status_standard == EXIT_SUCCESS)
		print_html_cell_semantic_file(job->path);
	else
		print_html_cell_ignored();

	int status = job->status_standard;
	if (job->is_negative)
	{
		if (status == EXIT_SUCCESS)
			status = EXIT_FAILURE;
		else
			status = EXIT_SUCCESS;
	}

	if (status == EXIT_SUCCESS)
		(*pass)++;

	sprintf(msg, " (<a href=\"%s.stderr\">log</a>)", job->path);
	print_html_cell_pass_fail(status, msg);

	if (job->test_behaviour)
	{
		sprintf(msg, " (<a href=\"%s.behaviour\">result</a>, "
			"<a href=\"%s.expected\">expected</a>)",
			job->path, job->path);
		print_html_cell_pass_fail(job->status_behaviour, msg);

		if (job->status_behaviour == EXIT_SUCCESS)
			(*pass_behaviour)++;
	}
	else
	{
		print_html_cell_ignored();
	}

	if (job->test_reingest)
	{
		sprintf(msg, " (<a href=\"%s.restderr\">log</a>)", job->path);
		print_html_cell_pass_fail_non_crit(job->status_reingest, msg);

		if (job->status_reingest == EXIT_SUCCESS)
			(*pass_reingest)++;
	}
	else
	{
		print_html_cell_ignored();
	}

	if (job->test_vgo)
	{
		sprintf(msg, " (<a href=\"%s.vgo\">log</a>)", job->path);
		print_html_cell_pass_fail(job->status_vgo, msg);

		if (job->status_vgo == EXIT_SUCCESS)
			(*pass_vgo)++;
		else
			(*fail_vgo)++;
	}
	else
	{
		print_html_cell_ignored();
	}

	if (job->test_vg)
	{
		sprintf(msg, " (<a href=\"./%s.vg\">log</a>)", job->path);
		print_html_cell_pass_fail(job->status_vg, msg);

		if (job->status_vg == EXIT_SUCCESS)
			(*pass_vg)++;
	}
	else
	{
		print_html_cell_ignored();
	}
}



typedef struct
{
	char*    path;
	unsigned count;
	job_t**  job;

	bool test_behaviour;
	bool test_reingest;
	bool test_vg;
} job_dir_t;

static unsigned    job_dir_count = 0;
static job_dir_t** job_dir = NULL;

static void job_dir_delete(job_dir_t* jd)
{
	if (!jd) return;

	free(jd->path);
	free(jd->job);
	free(jd);
}

static job_dir_t* job_dir_create(const char* path,
	bool test_behaviour,
	bool test_reingest,
	bool test_vg)
{
	job_dir_t* jd = (job_dir_t*)malloc(sizeof(job_dir_t));
	if (!jd) return NULL;

	jd->path = strdup(path);
	if(!jd->path)
	{
		free(jd);
		return NULL;
	}

	jd->count = 0;
	jd->job = NULL;

	jd->test_behaviour = test_behaviour;
	jd->test_reingest  = test_reingest;
	jd->test_vg        = test_vg;

	job_dir_t** njob_dir = (job_dir_t**)realloc(job_dir,
		(sizeof(job_dir_t*) * (job_dir_count + 1)));
	if (!njob_dir)
	{
		job_dir_delete(jd);
		return NULL;
	}
	job_dir = njob_dir;
	job_dir[job_dir_count++] = jd;

	return jd;
}

static bool job_dir_add(job_dir_t* jd, job_t* j)
{
	if (!jd || !j)
		return false;

	job_t** njob = (job_t**)realloc(jd->job,
		(sizeof(job_t*) * (jd->count + 1)));
	if (!njob) return false;
	jd->job = njob;

	jd->job[jd->count++] = j;
	return true;
}

static void job_dir_print(job_dir_t* jd)
{
	if (!jd || (jd->count == 0))
		return;

	print_html_table_start(jd->path);

	const char* headings[] =
	{
		"Source",
		"Semantic",
		"Standard",
		"Behaviour",
		"Reingest",
		"Valgrind",
		"Valgrind (Debug)",
		NULL
	};
	print_html_table_header(headings);

	unsigned pass           = 0;
	unsigned pass_behaviour = 0;
	unsigned pass_reingest  = 0;
	unsigned pass_vgo       = 0;
	unsigned fail_vgo       = 0;
	unsigned pass_vg        = 0;

	unsigned i;
	for (i = 0; i < jd->count; i++)
	{
		if (!jd->job[i])
			continue;

		job_print(jd->job[i],
			&pass,
			&pass_behaviour,
			&pass_reingest,
			&pass_vgo,
			&fail_vgo,
			&pass_vg);
	}

	print_html_table_row_start();
	print_html_cell_bold("Total");
	print_html_cell_centre("");

	char totals[64];

	sprintf(totals, "%u / %u", pass, jd->count);
	print_html_cell_centre(totals);

	if (jd->test_behaviour)
	{
		sprintf(totals, "%u / %u", pass_behaviour, pass);
		print_html_cell_centre(totals);
	}
	else
	{
		print_html_cell_ignored();
	}

	if (jd->test_reingest)
	{
		sprintf(totals, "%u / %u", pass_reingest, pass);
		print_html_cell_centre(totals);
	}
	else
	{
		print_html_cell_ignored();
	}

	if (jd->test_vg)
	{
		sprintf(totals, "%u / %u", pass_vgo, pass);
		print_html_cell_centre(totals);

		if (fail_vgo > 0)
		{
			sprintf(totals, "%u / %u", pass_vg, fail_vgo);
			print_html_cell_centre(totals);
		}
		else
		{
			print_html_cell_ignored();
		}
	}
	else
	{
		print_html_cell_ignored();
		print_html_cell_ignored();
	}

	print_html_table_row_end();

	print_html_table_end();
}



static void job_cleanup(void)
{
	unsigned i;
	for (i = 0; i < job_dir_count; i++)
		job_dir_delete(job_dir[i]);
	free(job_dir);

	for (i = 0; i < job_count; i++)
		job_delete(job[i]);
	free(job);
}


typedef struct
{
	unsigned count, ptr;
	struct dirent* entry;
} DIR_SORT;

static void closedir_sort(DIR_SORT* ds)
{
	if (!ds) return;
	free(ds->entry);
	free(ds);
}

/* Returns true if A should come before B. */
static bool opendir_sort__sort(
	struct dirent a,
	struct dirent b)
{
	/* Directories come after files. */
	if ((a.d_type == DT_DIR)
		&& (b.d_type != DT_DIR))
		return false;

	if ((b.d_type == DT_DIR)
		&& (a.d_type != DT_DIR))
		return true;

	unsigned i;
	for (i = 0; true; i++)
	{
		if (a.d_name[i] < b.d_name[i])
			return true;

		if (a.d_name[i] > b.d_name[i])
			return false;

		if (a.d_name[i] == '\0')
			break;
	}

	return true;
}

static DIR_SORT* opendir_sort(const char* path)
{
	DIR* d = opendir(path);
	if (!d) return NULL;

	DIR_SORT* ds = (DIR_SORT*)malloc(sizeof(DIR_SORT));
	if (!ds)
	{
		closedir(d);
		return NULL;
	}

	ds->ptr   = 0;
	ds->count = 0;
	ds->entry = NULL;

	while (true)
	{
		struct dirent* entry = readdir(d);
		if (errno != 0)
		{
			closedir_sort(ds);
			closedir(d);
			return NULL;
		}
		if (!entry) break;

		struct dirent* nentry
			= (struct dirent*)realloc(ds->entry,
				(sizeof(struct dirent) * (ds->count + 1)));
		if (!nentry)
		{
			closedir_sort(ds);
			closedir(d);
			return NULL;
		}
		ds->entry = nentry;

		ds->entry[ds->count++] = *entry;
	}

	closedir(d);

	unsigned last;
	for (last = (ds->count - 1); last > 0; last--)
	{
		unsigned i;
		for (i = 0; i < last; i++)
		{
			if (!opendir_sort__sort(
				ds->entry[i], ds->entry[i + 1]))
			{
				struct dirent swap = ds->entry[i];
				ds->entry[i] = ds->entry[i + 1];
				ds->entry[i + 1] = swap;
			}
		}
	}

	return ds;
}

static struct dirent* readdir_sort(DIR_SORT* ds)
{
	if (!ds)
	{
		errno = ENOENT;
		return NULL;
	}

	if (ds->ptr >= ds->count)
		return NULL;

	return &ds->entry[ds->ptr++];
}


static bool job_scan(char* path, bool test_vg)
{
	char* dir_name = basename(path);
	if ((strncmp(dir_name, ".", 1) == 0)
		|| (strcmp(dir_name, "stdin") == 0)
		|| (strcmp(dir_name, "stdout") == 0)
		|| (strcmp(dir_name, "include") == 0))
		return true;

	bool is_negative = (strcmp(dir_name, "negative") == 0);
	bool is_sema     = (strcmp(dir_name, "sema"    ) == 0);

	bool test_behaviour = true;
	bool test_reingest  = true;

	if (is_sema)
		test_behaviour = false;

	if (is_negative)
	{
		test_behaviour = false;
		test_reingest  = false;
		test_vg        = false;
	}

	DIR_SORT* d = opendir_sort(path);
	if (!d) return false;

	size_t path_len = strlen(path);

	job_dir_t* jd = NULL;

	while (true)
	{
		struct dirent* entry = readdir_sort(d);
		if (errno != 0)
		{
			closedir_sort(d);
			return false;
		}
		if (!entry) break;

		char epath[path_len + strlen(entry->d_name) + 2];
		sprintf(epath, "%s/%s", path, entry->d_name);

		struct stat s;
		if (stat(epath, &s) < 0)
		{
			closedir_sort(d);
			return false;
		}

		int ifmt = (s.st_mode & S_IFMT);
		if (ifmt == S_IFREG)
		{
			job_t* j = job_create(
				epath, is_negative,
				test_behaviour,
				test_reingest,
				test_vg);
			if (!j)
			{
				closedir_sort(d);
				return false;
			}

			if (!jd)
			{
				jd = job_dir_create(
					path, test_behaviour,
					test_reingest, test_vg);
				if (!jd)
				{
					closedir_sort(d);
					return false;
				}
			}

			if (!job_dir_add(jd, j))
			{
				closedir_sort(d);
				return false;
			}
		}
		else if (ifmt == S_IFDIR)
		{
			if (!job_scan(epath, test_vg))
			{
				closedir_sort(d);
				return false;
			}
		}
		else
		{
			fprintf(stderr, "Unknown file type '%s'.\n", epath);
			closedir_sort(d);
			return false;
		}
	}

	closedir_sort(d);
	return true;
}

struct job_exec_all_params
{
	char*    ofc;
	unsigned threads;

	volatile bool success;
};

static void* job_exec_all(
	struct job_exec_all_params* params)
{
	if (!params)
		return NULL;

	pthread_t thread[job_count];
	struct job_exec_params jparams[job_count];

	unsigned t = params->threads;

	unsigned i;
	for (i = 0; i < job_count; i++)
	{
		if (t == 0)
		{
			sem_wait(&job_exec_sem);
			t++;
		}

		jparams[i].job = job[i];
		jparams[i].ofc = params->ofc;

		if (pthread_create(&thread[i], NULL,
			(void*)job_exec, &jparams[i]) != 0)
		{
			params->success = false;
			continue;
		}

		t--;
	}

	for (i = 0; i < job_count; i++)
		pthread_join(thread[i], NULL);

	return NULL;
}

static void job_print_all(void)
{
	print_html_header();
	print_html_report_info();

	unsigned i;
	for (i = 0; i < job_dir_count; i++)
		job_dir_print(job_dir[i]);

	print_html_footer();
}



static unsigned env_count = 0;
static char**   env_value = NULL;

static void env_cleanup(void)
{
	unsigned i;
	for (i = 0; i < env_count; i++)
		free(env_value[i]);
	free(env_value);
}

static char* env_get(const char* name)
{
	char** nvalue = (char**)realloc(env_value,
		(sizeof(char*) * (env_count + 1)));
	if (!nvalue) return NULL;
	env_value = nvalue;

	char* v = getenv(name);
	if (!v)
	{
		fprintf(stderr, "Error: '%s' not set", name);
		return NULL;
	}

	char* d = strdup(v);
	env_value[env_count++] = d;
	return d;
}

#define ENV_INIT(x) do { x = env_get(#x); if (!x) return EXIT_FAILURE; } while (0)

int main(int argc, char* argv[])
{
	if ((argc < 2) || (argc > 4))
		return EXIT_FAILURE;

	bool test_vg = false;
	if (argc >= 3)
	{
		if (strcmp(argv[2], "1") == 0)
			test_vg = true;
		else if (strcmp(argv[2], "0") != 0)
			abort();
	}

	unsigned threads = 1;
	if (argc >= 4)
	{
		if (sscanf(argv[3], "%u", &threads) != 1)
			return EXIT_FAILURE;
	}

	ENV_INIT(OFC_GIT_COMMIT);
	ENV_INIT(OFC_GIT_BRANCH);
	ENV_INIT(TESTS_GIT_COMMIT);

	OFC_GIT_URL   = "https://github.com/CodethinkLabs/ofc";
	TESTS_GIT_URL = "https://github.com/CodethinkLabs/ofc-tests";

	if (!job_scan("programs", test_vg))
		abort();

	if ((sem_init(&job_exec_sem, 0, 0) != 0)
		|| (sem_init(&job_print_sem, 0, 0) != 0))
		abort();

	pthread_t exec_thread;
	struct job_exec_all_params exec_params =
	{
		.ofc      = argv[1],
		.threads  = threads,
		.success  = true,
	};
	if (pthread_create(&exec_thread, NULL,
		(void*)job_exec_all, &exec_params) != 0)
		abort();

	job_print_all();

	pthread_join(exec_thread, NULL);

	sem_destroy(&job_exec_sem);
	sem_destroy(&job_print_sem);

	job_cleanup();
	env_cleanup();

	if (!exec_params.success)
		return EXIT_FAILURE;
	return EXIT_SUCCESS;
}
